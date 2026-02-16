defmodule CloseTheLoopWeb.ReportsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback
  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:reports, [])
      |> assign(:q, nil)
      |> assign(:filters_form, to_form(%{"q" => ""}, as: :filters))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tenant = socket.assigns.current_tenant
    q = parse_q(params["q"])

    socket =
      socket
      |> assign(:q, q)
      |> assign(:filters_form, to_form(%{"q" => q || ""}, as: :filters))

    case list_reports(tenant, q) do
      {:ok, reports} ->
        {:noreply, assign(socket, :reports, reports)}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to load reports")}
    end
  end

  @impl true
  def handle_event("filters_changed", %{"filters" => %{"q" => q}}, socket) do
    q = q |> to_string() |> String.trim()
    q = if q == "", do: nil, else: q

    {:noreply,
     push_patch(socket,
       to: reports_index_path(socket.assigns.current_org.id, q)
     )}
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply, push_patch(socket, to: reports_index_path(socket.assigns.current_org.id, nil))}
  end

  defp list_reports(tenant, q) when is_binary(tenant) do
    query =
      CloseTheLoop.Feedback.Report
      |> Ash.Query.for_read(:read, %{})
      |> Ash.Query.sort(updated_at: :desc, inserted_at: :desc)
      |> Ash.Query.limit(200)

    query =
      if q do
        Ash.Query.filter(query, contains(body, ^q))
      else
        query
      end

    Feedback.list_reports(
      tenant: tenant,
      query: query,
      load: [issue: [:title], location: [:name, :full_path]]
    )
  end

  defp list_reports(_tenant, _q), do: {:ok, []}

  defp normalize_whitespace(body) do
    body
    |> to_string()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  defp format_dt(other), do: to_string(other)

  defp iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp iso8601(other) when is_binary(other), do: other
  defp iso8601(other), do: to_string(other)

  defp reports_index_path(org_id, q) do
    params = if q, do: %{q: q}, else: %{}
    ~p"/app/#{org_id}/reports?#{params}"
  end

  defp parse_q(nil), do: nil

  defp parse_q(q) do
    q = q |> to_string() |> String.trim()
    if q == "", do: nil, else: q
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_user={@current_user}
      current_scope={@current_scope}
      org={@current_org}
    >
      <div class="max-w-5xl mx-auto">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 class="text-2xl font-semibold">Reports</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Search and click any report to view details.
            </p>
          </div>

          <div class="flex items-center gap-2">
            <.form for={@filters_form} id="reports-filters-form" phx-change="filters_changed">
              <.input
                field={@filters_form[:q]}
                type="search"
                placeholder="Search reports..."
                phx-debounce="300"
              >
                <:inner_prefix>
                  <.icon name="hero-magnifying-glass" class="icon" />
                </:inner_prefix>
                <:inner_suffix :if={@q}>
                  <.button
                    type="button"
                    size="icon-sm"
                    variant="ghost"
                    phx-click="clear_search"
                    aria-label="Clear search"
                  >
                    <.icon name="hero-x-mark" class="icon" />
                  </.button>
                </:inner_suffix>
              </.input>
            </.form>

            <.button navigate={~p"/app/#{@current_org.id}/reports/new"} variant="outline">
              New report
            </.button>
          </div>
        </div>

        <%!-- Card list (no tables, no horizontal scrolling) --%>
        <div class="mt-6 rounded-2xl border border-base bg-base shadow-base overflow-hidden">
          <div :if={@reports == []} class="py-12 text-center text-sm text-foreground-soft">
            No reports yet.
          </div>

          <div :if={@reports != []} class="divide-y divide-base">
            <.link
              :for={r <- @reports}
              id={"report-#{r.id}"}
              navigate={~p"/app/#{@current_org.id}/reports/#{r.id}"}
              class={[
                "block p-4 sm:p-5 transition cursor-pointer",
                "hover:bg-accent"
              ]}
            >
              <div class="flex items-start gap-4">
                <div class="min-w-0 flex-1">
                  <div class="flex flex-wrap items-center gap-2">
                    <.badge variant="soft" color="primary">{format_source(r.source)}</.badge>
                    <time
                      id={"reports-index-time-#{r.id}"}
                      phx-hook="LocalTime"
                      data-iso={iso8601(r.inserted_at)}
                      class="text-xs text-foreground-soft whitespace-nowrap"
                    >
                      {format_dt(r.inserted_at)}
                    </time>
                    <.icon name="hero-arrow-right" class="ml-auto size-4 text-foreground-soft" />
                  </div>

                  <p class="mt-2 text-sm font-medium text-foreground line-clamp-2">
                    {normalize_whitespace(r.body)}
                  </p>

                  <div class="mt-3 grid gap-1 text-xs text-foreground-soft">
                    <div class="flex items-start gap-2 min-w-0">
                      <.icon name="hero-map-pin" class="mt-0.5 size-4 shrink-0" />
                      <span class="truncate" title={r.location.full_path || r.location.name}>
                        {r.location.full_path || r.location.name}
                      </span>
                    </div>
                    <div class="flex items-start gap-2 min-w-0">
                      <.icon name="hero-inbox" class="mt-0.5 size-4 shrink-0" />
                      <span class="min-w-0 line-clamp-1" title={r.issue.title}>
                        {r.issue.title}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_source(source) when is_atom(source),
    do: source |> Atom.to_string() |> String.upcase()

  defp format_source(source), do: source |> to_string() |> String.upcase()
end
