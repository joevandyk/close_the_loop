defmodule CloseTheLoopWeb.LocationsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Feedback.Location

  @impl true
  def mount(_params, _session, socket) do
    tenant = socket.assigns.current_tenant
    org = socket.assigns.current_org

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, locations} <- list_locations(tenant) do
      {:ok,
       socket
       |> assign(:org, org)
       |> assign(:locations, decorate_locations(tenant, locations))
       |> assign(:location_modal_open?, false)
       |> assign(:editing_id, nil)
       |> assign(:location_form, to_form(%{"name" => "", "full_path" => ""}, as: :location))
       |> assign(:error, nil)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load locations")}
    end
  end

  defp list_locations(tenant) do
    FeedbackDomain.list_locations(tenant: tenant, query: [sort: [inserted_at: :asc]])
  end

  defp decorate_locations(tenant, locations) do
    Enum.map(locations, fn loc ->
      reporter_link = CloseTheLoopWeb.Endpoint.url() <> "/r/#{tenant}/#{loc.id}"

      %{
        id: loc.id,
        name: loc.name,
        full_path: loc.full_path,
        reporter_link: reporter_link
      }
    end)
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
      <div class="max-w-5xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Locations</h1>
            <p class="mt-2 text-foreground-soft text-sm">
              Create a QR code for each location. Each location has its own reporter link.
            </p>
          </div>

          <.button
            id="locations-open-new"
            type="button"
            variant="solid"
            color="primary"
            phx-click="open_new_location_modal"
          >
            <.icon name="hero-plus" class="size-4" /> Add location
          </.button>
        </div>

        <.modal
          id="location-modal"
          open={@location_modal_open?}
          on_close={JS.push("close_location_modal")}
          class="w-full max-w-lg"
        >
          <div class="p-6 space-y-4">
            <div>
              <h2 class="text-lg font-semibold">
                <%= if @editing_id do %>
                  Edit location
                <% else %>
                  Add location
                <% end %>
              </h2>
              <p class="mt-1 text-sm text-foreground-soft">
                Used on posters and in reporting links.
              </p>
            </div>

            <.form for={@location_form} id="location-modal-form" phx-submit="save" class="space-y-4">
              <.input
                id="location-modal-name"
                field={@location_form[:name]}
                type="text"
                label="Name"
                placeholder="Downtown"
                required
              />

              <.input
                id="location-modal-full-path"
                field={@location_form[:full_path]}
                type="text"
                label="Full path (optional)"
                placeholder="Building A / Floor 2"
              />

              <%= if @error do %>
                <.alert color="danger" hide_close>{@error}</.alert>
              <% end %>

              <div class="flex items-center justify-end gap-2 pt-2">
                <.button
                  id="location-modal-cancel"
                  type="button"
                  variant="outline"
                  phx-click="close_location_modal"
                >
                  Cancel
                </.button>

                <.button type="submit" variant="solid" color="primary" phx-disable-with="Saving...">
                  <%= if @editing_id do %>
                    Save changes
                  <% else %>
                    Create location
                  <% end %>
                </.button>
              </div>
            </.form>
          </div>
        </.modal>

        <.alert color="info" title="Tips">
          <ul class="text-sm space-y-1">
            <li>Print the QR code and post it where customers will see it.</li>
            <li>Use one location per physical site or area (e.g. locker room).</li>
            <li>Customers can optionally opt in to SMS updates.</li>
          </ul>
        </.alert>

        <div class="space-y-3">
          <div
            :for={loc <- @locations}
            data-location-card
            id={"location-item-#{loc.id}"}
            class="rounded-2xl border border-base bg-base p-5 shadow-base"
          >
            <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
              <div class="min-w-0">
                <div class="text-sm font-semibold text-foreground truncate">
                  {loc.full_path || loc.name}
                </div>
                <div class="mt-1 text-xs text-foreground-soft">
                  Reporter link + poster for this location
                </div>
              </div>

              <div class="flex flex-wrap items-center gap-2 sm:justify-end">
                <.button
                  href={loc.reporter_link}
                  target="_blank"
                  rel="noreferrer"
                  variant="outline"
                  size="sm"
                >
                  <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Open reporter
                </.button>

                <.button
                  href={~p"/app/#{@current_org.id}/settings/locations/#{loc.id}/poster"}
                  target="_blank"
                  rel="noreferrer"
                  variant="outline"
                  size="sm"
                >
                  <.icon name="hero-printer" class="size-4" /> Poster (PDF)
                </.button>

                <.button
                  id={"locations-open-edit-#{loc.id}"}
                  type="button"
                  size="sm"
                  variant="solid"
                  color="primary"
                  phx-click="edit"
                  phx-value-id={loc.id}
                >
                  <.icon name="hero-pencil-square" class="size-4" /> Edit
                </.button>
              </div>
            </div>
          </div>

          <div :if={@locations == []} class="py-10 text-center text-sm text-foreground-soft">
            No locations yet.
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("open_new_location_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:location_modal_open?, true)
     |> assign(:editing_id, nil)
     |> assign(:location_form, to_form(%{"name" => "", "full_path" => ""}, as: :location))
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("close_location_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:location_modal_open?, false)
     |> assign(:editing_id, nil)
     |> assign(:location_form, to_form(%{"name" => "", "full_path" => ""}, as: :location))
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.locations, &("#{&1.id}" == to_string(id))) do
      nil ->
        {:noreply, put_flash(socket, :error, "Location not found")}

      loc ->
        {:noreply,
         socket
         |> assign(:location_modal_open?, true)
         |> assign(:editing_id, loc.id)
         |> assign(
           :location_form,
           to_form(%{"name" => loc.name || "", "full_path" => loc.full_path || ""}, as: :location)
         )
         |> assign(:error, nil)}
    end
  end

  @impl true
  def handle_event("save", %{"location" => params}, socket) when is_map(params) do
    tenant = socket.assigns.current_tenant
    user = socket.assigns.current_user

    name = params |> Map.get("name", "") |> to_string() |> String.trim()
    full_path = params |> Map.get("full_path", "") |> to_string() |> String.trim()

    socket =
      assign(
        socket,
        :location_form,
        to_form(%{"name" => name, "full_path" => full_path}, as: :location)
      )

    full_path =
      case full_path do
        "" -> nil
        v -> v
      end

    result =
      case socket.assigns.editing_id do
        nil ->
          FeedbackDomain.create_location(%{name: name, full_path: full_path},
            tenant: tenant,
            actor: user
          )

        id ->
          with {:ok, %Location{} = loc} <- FeedbackDomain.get_location_by_id(id, tenant: tenant) do
            FeedbackDomain.update_location(loc, %{name: name, full_path: full_path},
              tenant: tenant,
              actor: user
            )
          end
      end

    with true <- name != "" || {:error, "Name is required"},
         {:ok, %Location{}} <- result,
         {:ok, locations} <- list_locations(tenant) do
      flash_msg =
        if socket.assigns.editing_id do
          "Location updated."
        else
          "Location created."
        end

      {:noreply,
       socket
       |> put_flash(:info, flash_msg)
       |> assign(:locations, decorate_locations(tenant, locations))
       |> assign(:location_modal_open?, false)
       |> assign(:editing_id, nil)
       |> assign(:location_form, to_form(%{"name" => "", "full_path" => ""}, as: :location))
       |> assign(:error, nil)}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}

      other ->
        {:noreply, assign(socket, :error, "Failed to save: #{inspect(other)}")}
    end
  end
end
