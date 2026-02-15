defmodule CloseTheLoopWeb.ReporterLive.New do
  use CloseTheLoopWeb, :live_view

  alias CloseTheLoop.Feedback.{Intake, Location}
  alias CloseTheLoop.Messaging.Phone

  @impl true
  def mount(%{"tenant" => tenant, "location_id" => location_id}, _session, socket) do
    socket =
      socket
      |> assign(:tenant, tenant)
      |> assign(:location_id, location_id)
      |> assign(:body, "")
      |> assign(:name, "")
      |> assign(:email, "")
      |> assign(:phone, "")
      |> assign(:consent, false)
      |> assign(:submitted, false)
      |> assign(:error, nil)

    case Ash.get(Location, location_id, tenant: tenant) do
      {:ok, %Location{} = location} ->
        {:ok, assign(socket, :location, location)}

      {:ok, nil} ->
        {:ok, assign(socket, :location, nil) |> assign(:error, "Unknown location")}

      {:error, err} ->
        {:ok, assign(socket, :location, nil) |> assign(:error, Exception.message(err))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-5">
      <div class="space-y-1">
        <h1 class="text-2xl font-semibold tracking-tight">Report an issue</h1>
        <p :if={@location} class="text-sm text-foreground-soft">
          Location:
          <span class="font-medium text-foreground">{@location.full_path || @location.name}</span>
        </p>
      </div>

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
          <.form for={%{}} as={:report} phx-submit="submit" class="space-y-4">
            <.textarea
              id="body"
              name="report[body]"
              label="What's wrong?"
              rows={4}
              placeholder="Cold water in the men's showers"
              value={@body}
              required
            />

            <div class="space-y-2">
              <.input
                id="reporter_name"
                name="report[name]"
                type="text"
                label="Your name"
                sublabel="Optional"
                value={@name}
                autocomplete="name"
              />

              <.input
                id="reporter_email"
                name="report[email]"
                type="email"
                label="Email"
                sublabel="Optional"
                value={@email}
                autocomplete="email"
                inputmode="email"
                help_text="Only used if the business needs to follow up."
              />

              <.input
                id="phone"
                name="report[phone]"
                type="tel"
                label="Phone number"
                sublabel="Optional"
                placeholder="+15555550100"
                value={@phone}
                inputmode="tel"
                autocomplete="tel"
                help_text="For international numbers, start with + and country code."
              />

              <.checkbox
                name="report[consent]"
                checked={@consent}
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
    """
  end

  @impl true
  def handle_event("submit", %{"report" => %{"body" => body} = params}, socket) do
    tenant = socket.assigns.tenant
    location_id = socket.assigns.location_id

    name_raw = Map.get(params, "name", "")
    email_raw = Map.get(params, "email", "")
    phone_raw = Map.get(params, "phone", "")
    wants_updates = Map.get(params, "consent") in ["true", "1", true]

    socket =
      socket
      |> assign(:body, body)
      |> assign(:name, name_raw)
      |> assign(:email, email_raw)
      |> assign(:phone, phone_raw)
      |> assign(:consent, wants_updates)

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
