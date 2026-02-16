defmodule CloseTheLoopWeb.Dev.SmsOutboxLive do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_optional}

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Messaging.OutboundDelivery
  alias Phoenix.LiveView.JS

  @limit 200

  @impl true
  def mount(_params, _session, socket) do
    filters = %{"status" => "", "tenant" => "", "to" => ""}

    socket =
      socket
      |> assign(:current_scope, nil)
      |> assign(:filters, filters)
      |> assign(:filters_form, to_form(filters, as: "filters"))
      |> assign(:deliveries, list_deliveries(filters))
      |> assign(:selected_delivery, nil)
      |> assign(:view_modal_open?, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("filters_changed", %{"filters" => params}, socket) when is_map(params) do
    filters =
      socket.assigns.filters
      |> Map.merge(params)
      |> Map.take(["status", "tenant", "to"])

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:filters_form, to_form(filters, as: "filters"))
     |> assign(:deliveries, list_deliveries(filters))}
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, assign(socket, :deliveries, list_deliveries(socket.assigns.filters))}
  end

  def handle_event("view", %{"id" => id}, socket) do
    delivery = get_delivery(id)

    {:noreply,
     socket
     |> assign(:selected_delivery, delivery)
     |> assign(:view_modal_open?, true)}
  end

  def handle_event("close_view_modal", _params, socket) do
    {:noreply, socket |> assign(:view_modal_open?, false) |> assign(:selected_delivery, nil)}
  end

  defp list_deliveries(filters) do
    status_filter = filters["status"] |> to_string() |> String.trim()
    tenant_filter = filters["tenant"] |> to_string() |> String.trim()
    to_filter = filters["to"] |> to_string() |> String.trim()

    query =
      OutboundDelivery
      |> Ash.Query.filter(expr(channel == :sms))
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(@limit)

    query =
      if status_filter != "" do
        case safe_to_existing_atom(status_filter) do
          nil -> query
          status -> Ash.Query.filter(query, expr(status == ^status))
        end
      else
        query
      end

    query =
      if tenant_filter != "" do
        Ash.Query.filter(query, expr(tenant == ^tenant_filter))
      else
        query
      end

    # Keep this as an in-memory filter to avoid relying on specific Ash string functions;
    # this is dev-only and limited to @limit rows.
    deliveries =
      case Ash.read(query, authorize?: false) do
        {:ok, results} -> results
        _ -> []
      end

    if to_filter == "" do
      deliveries
    else
      Enum.filter(deliveries, fn d ->
        (d.to || "") |> String.contains?(to_filter)
      end)
    end
  end

  defp get_delivery(id) do
    query =
      OutboundDelivery
      |> Ash.Query.filter(expr(id == ^id))

    case Ash.read_one(query, authorize?: false) do
      {:ok, delivery} -> delivery
      _ -> nil
    end
  end

  defp safe_to_existing_atom(value) when is_binary(value) do
    try do
      String.to_existing_atom(value)
    rescue
      _ -> nil
    end
  end

  defp status_color(:sent), do: "success"
  defp status_color(:failed), do: "danger"
  defp status_color(:noop), do: "warning"
  defp status_color(:queued), do: "info"
  defp status_color(_), do: "ghost"

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
  defp format_dt(_), do: "—"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} current_user={@current_user}>
      <div class="max-w-6xl mx-auto space-y-6">
        <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 class="text-2xl font-semibold">SMS Outbox</h1>
            <p class="mt-1 text-sm text-foreground-soft">
              Recent outbound SMS attempts (stored in Postgres).
            </p>
          </div>

          <.button type="button" variant="outline" size="sm" phx-click="refresh">
            <.icon name="hero-arrow-path" class="size-4" /> Refresh
          </.button>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <.form
            for={@filters_form}
            phx-change="filters_changed"
            class="grid grid-cols-1 gap-4 sm:grid-cols-3"
          >
            <.select
              field={@filters_form[:status]}
              label="Status"
              options={[
                {"All", ""},
                {"queued", "queued"},
                {"sent", "sent"},
                {"failed", "failed"},
                {"noop", "noop"}
              ]}
            />

            <.input field={@filters_form[:tenant]} type="text" label="Tenant" placeholder="org_..." />
            <.input field={@filters_form[:to]} type="text" label="To contains" placeholder="+1555..." />
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base shadow-base overflow-hidden">
          <div :if={@deliveries == []} class="py-12 text-center text-sm text-foreground-soft">
            No SMS deliveries recorded yet.
          </div>

          <.table :if={@deliveries != []}>
            <.table_head>
              <:col>When</:col>
              <:col>To</:col>
              <:col>Status</:col>
              <:col>Tenant</:col>
              <:col>Provider ID</:col>
              <:col></:col>
            </.table_head>
            <.table_body>
              <.table_row :for={d <- @deliveries} id={"sms-delivery-#{d.id}"}>
                <:cell class="font-mono text-xs">{format_dt(d.inserted_at)}</:cell>
                <:cell class="font-mono text-xs">{d.to}</:cell>
                <:cell>
                  <.badge variant="soft" color={status_color(d.status)}>{d.status}</.badge>
                </:cell>
                <:cell class="font-mono text-xs">{d.tenant || "—"}</:cell>
                <:cell class="font-mono text-xs">{d.provider_id || "—"}</:cell>
                <:cell class="text-right">
                  <.button
                    type="button"
                    size="sm"
                    variant="ghost"
                    phx-click="view"
                    phx-value-id={d.id}
                  >
                    View
                  </.button>
                </:cell>
              </.table_row>
            </.table_body>
          </.table>
        </div>

        <.modal
          id="sms-outbox-view-modal"
          open={@view_modal_open?}
          on_close={JS.push("close_view_modal")}
          class="w-full max-w-3xl"
        >
          <div class="p-6 space-y-4">
            <div class="flex items-start justify-between gap-4">
              <div>
                <h3 class="text-lg font-semibold">SMS Delivery</h3>
                <p class="mt-1 text-sm text-foreground-soft font-mono break-all">
                  {@selected_delivery && @selected_delivery.id}
                </p>
              </div>

              <.button type="button" variant="ghost" size="sm" phx-click="close_view_modal">
                Close
              </.button>
            </div>

            <div :if={!@selected_delivery} class="text-sm text-foreground-soft">
              Delivery not found.
            </div>

            <div :if={@selected_delivery} class="space-y-4">
              <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
                <div>
                  <div class="text-xs text-foreground-soft">To</div>
                  <div class="mt-1 font-mono text-sm break-all">{@selected_delivery.to}</div>
                </div>

                <div>
                  <div class="text-xs text-foreground-soft">Status</div>
                  <div class="mt-1">
                    <.badge variant="soft" color={status_color(@selected_delivery.status)}>
                      {@selected_delivery.status}
                    </.badge>
                  </div>
                </div>

                <div>
                  <div class="text-xs text-foreground-soft">Tenant</div>
                  <div class="mt-1 font-mono text-sm break-all">
                    {@selected_delivery.tenant || "—"}
                  </div>
                </div>

                <div>
                  <div class="text-xs text-foreground-soft">Provider ID</div>
                  <div class="mt-1 font-mono text-sm break-all">
                    {@selected_delivery.provider_id || "—"}
                  </div>
                </div>
              </div>

              <div>
                <div class="text-xs text-foreground-soft">Body</div>
                <pre class="mt-2 whitespace-pre-wrap break-words rounded-xl border border-base bg-accent p-4 text-xs text-foreground"><%= @selected_delivery.body %></pre>
              </div>

              <div :if={@selected_delivery.error}>
                <div class="text-xs text-foreground-soft">Error</div>
                <pre class="mt-2 whitespace-pre-wrap break-words rounded-xl border border-base bg-accent p-4 text-xs text-foreground"><%= @selected_delivery.error %></pre>
              </div>

              <div :if={@selected_delivery.provider_response}>
                <div class="text-xs text-foreground-soft">Provider response</div>
                <pre class="mt-2 whitespace-pre-wrap break-words rounded-xl border border-base bg-accent p-4 text-xs text-foreground"><%= inspect(@selected_delivery.provider_response, pretty: true, limit: :infinity) %></pre>
              </div>
            </div>
          </div>
        </.modal>
      </div>
    </Layouts.app>
    """
  end
end
