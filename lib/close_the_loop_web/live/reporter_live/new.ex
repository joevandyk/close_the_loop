defmodule CloseTheLoopWeb.ReporterLive.New do
  use CloseTheLoopWeb, :live_view

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Tenants
  alias CloseTheLoop.Tenants.Organization
  alias CloseTheLoop.Feedback.{Intake, Location}
  alias CloseTheLoop.Messaging.Phone

  @impl true
  def mount(%{"tenant" => tenant, "location_id" => location_id}, _session, socket) do
    socket =
      socket
      |> assign_new(:current_user, fn -> nil end)
      |> assign(:current_scope, %{actor: nil, tenant: tenant})
      |> assign(:tenant, tenant)
      |> assign(:location_id, location_id)
      |> assign(:org, get_org_by_tenant(tenant))
      |> assign(
        :report_form,
        to_form(%{"body" => "", "name" => "", "email" => "", "phone" => "", "consent" => "false"},
          as: :report
        )
      )
      |> assign(:submitted, false)
      |> assign(:error, nil)

    case FeedbackDomain.get_location_by_id(location_id, tenant: tenant) do
      {:ok, %Location{} = location} ->
        {:ok, assign(socket, :location, location)}

      {:ok, nil} ->
        {:ok, assign(socket, :location, nil) |> assign(:error, "Unknown location")}

      {:error, err} ->
        {:ok, assign(socket, :location, nil) |> assign(:error, Exception.message(err))}
    end
  end

  defp get_org_by_tenant(tenant) when is_binary(tenant) do
    case Tenants.get_organization_by_tenant_schema(tenant) do
      {:ok, %Organization{} = org} -> org
      _ -> nil
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      variant={:reporter}
      flash={@flash}
      current_user={@current_user}
      current_scope={@current_scope}
      org={@org}
      location={@location}
    >
      <div class="space-y-5">
        <h2 class="text-2xl font-semibold tracking-tight">Report an issue</h2>

        <div class="rounded-2xl border border-base bg-base p-5 shadow-base">
          <%= if @submitted do %>
            <div class="space-y-4">
              <.alert color="success" hide_close>
                Got it. We'll update you.
              </.alert>

              <p class="text-sm text-foreground-soft">
                If you opted into text updates, we will send status changes to your phone.
              </p>

              <.button href={~p"/r/#{@tenant}/#{@location_id}"} variant="outline">
                Report another issue
              </.button>
            </div>
          <% else %>
            <.form for={@report_form} id="reporter-intake-form" phx-submit="submit" class="space-y-4">
              <.textarea
                field={@report_form[:body]}
                label="What's wrong?"
                rows={4}
                placeholder="Cold water in the men's showers"
                required
              />

              <div class="space-y-2">
                <.input
                  field={@report_form[:name]}
                  type="text"
                  label="Your name"
                  sublabel="Optional"
                  autocomplete="name"
                />

                <.input
                  field={@report_form[:email]}
                  type="email"
                  label="Email"
                  sublabel="Optional"
                  autocomplete="email"
                  inputmode="email"
                  help_text="Only used if the business needs to follow up."
                />

                <.input
                  field={@report_form[:phone]}
                  type="tel"
                  label="Phone number"
                  sublabel="Optional"
                  placeholder="+15555550100"
                  inputmode="tel"
                  autocomplete="tel"
                  help_text="For international numbers, start with + and country code."
                />

                <.checkbox
                  field={@report_form[:consent]}
                  label="I agree to receive text updates about this issue."
                />
              </div>

              <%= if @error do %>
                <.alert color="danger" hide_close>
                  {@error}
                </.alert>
              <% end %>

              <.button
                type="submit"
                variant="solid"
                color="primary"
                class="w-full"
                phx-disable-with="Submitting..."
              >
                Submit
              </.button>
            </.form>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("submit", %{"report" => %{"body" => body} = params}, socket) do
    tenant = socket.assigns.tenant
    location_id = socket.assigns.location_id

    name_raw = Map.get(params, "name", "") |> to_string()
    email_raw = Map.get(params, "email", "") |> to_string()
    phone_raw = Map.get(params, "phone", "") |> to_string()
    wants_updates = Map.get(params, "consent") in ["true", "1", true]

    socket = assign(socket, :report_form, to_form(params, as: :report))

    with {:ok, phone} <- Phone.normalize_e164(phone_raw),
         {:ok, _} <-
           Intake.submit_report(tenant, location_id, %{
             body: body,
             source: :qr,
             reporter_name: name_raw,
             reporter_email: email_raw,
             reporter_phone: phone,
             consent: wants_updates and not is_nil(phone)
           }) do
      {:noreply, assign(socket, :submitted, true)}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, inspect(err))}
    end
  end
end
