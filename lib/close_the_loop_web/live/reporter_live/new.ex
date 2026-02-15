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
    <div class="max-w-lg mx-auto p-4">
      <%= if @submitted do %>
        <div class="alert alert-success">
          <span>Got it. We'll update you.</span>
        </div>
      <% else %>
        <h1 class="text-xl font-semibold">Report an issue</h1>

        <%= if @location do %>
          <p class="text-base-content/70 mt-1">
            Location: <span class="font-medium">{@location.full_path || @location.name}</span>
          </p>
        <% end %>

        <.form for={%{}} as={:report} phx-submit="submit" class="mt-5 space-y-4">
          <div class="form-control">
            <label class="label" for="body">
              <span class="label-text">What's wrong?</span>
            </label>
            <textarea
              id="body"
              name="report[body]"
              class="textarea textarea-bordered w-full"
              rows="4"
              placeholder="Cold water in the men’s showers"
              required
            ><%= @body %></textarea>
          </div>

          <div class="form-control">
            <label class="label" for="phone">
              <span class="label-text">Text me updates (optional)</span>
            </label>
            <input
              id="phone"
              name="report[phone]"
              type="tel"
              value={@phone}
              class="input input-bordered w-full"
              placeholder="+1 555 555 5555"
              inputmode="tel"
            />
            <label class="label cursor-pointer gap-3 justify-start mt-2">
              <input
                type="checkbox"
                name="report[consent]"
                class="checkbox"
                value="true"
                checked={@consent}
              />
              <span class="label-text">I agree to receive text updates about this issue.</span>
            </label>
          </div>

          <%= if @error do %>
            <div class="alert alert-error">
              <span>{@error}</span>
            </div>
          <% end %>

          <button type="submit" class="btn btn-primary w-full">Submit</button>
        </.form>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("submit", %{"report" => %{"body" => body} = params}, socket) do
    tenant = socket.assigns.tenant
    location_id = socket.assigns.location_id

    phone_raw = Map.get(params, "phone", "")
    wants_updates = Map.has_key?(params, "consent")

    socket =
      socket
      |> assign(:body, body)
      |> assign(:phone, phone_raw)
      |> assign(:consent, wants_updates)

    with {:ok, phone} <- Phone.normalize_e164(phone_raw),
         {:ok, _} <-
           Intake.submit_report(tenant, location_id, %{
             body: body,
             source: :qr,
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
