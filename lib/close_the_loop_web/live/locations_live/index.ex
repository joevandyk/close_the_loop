defmodule CloseTheLoopWeb.LocationsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Location
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         {:ok, locations} <- list_locations(tenant) do
      {:ok,
       socket
       |> assign(:tenant, tenant)
       |> assign(:org, org)
       |> assign(:locations, decorate_locations(tenant, locations))
       |> assign(:editing_id, nil)
       |> assign(:name, "")
       |> assign(:full_path, "")
       |> assign(:error, nil)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load locations")}
    end
  end

  defp list_locations(tenant) do
    query = Location |> Ash.Query.sort(inserted_at: :asc)
    Ash.read(query, tenant: tenant)
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
    <div class="max-w-5xl mx-auto space-y-8">
      <div>
        <h1 class="text-2xl font-semibold">Locations</h1>
        <p class="mt-2 text-foreground-soft text-sm">
          Create a QR code for each location. Each location has its own reporter link.
        </p>
      </div>

      <div class="grid gap-6 lg:grid-cols-2">
        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">
            <%= if @editing_id do %>
              Edit location
            <% else %>
              Add a location
            <% end %>
          </h2>

          <.form for={%{}} as={:location} phx-submit="save" class="mt-4 space-y-4">
            <.input
              id="location_name"
              name="name"
              type="text"
              label="Name"
              value={@name}
              placeholder="Downtown"
              required
            />

            <.input
              id="location_full_path"
              name="full_path"
              type="text"
              label="Full path (optional)"
              value={@full_path}
              placeholder="Building A / Floor 2"
            />

            <%= if @error do %>
              <.alert color="danger" hide_close>{@error}</.alert>
            <% end %>

            <div class="flex gap-2">
              <.button type="submit" variant="solid" color="primary" class="flex-1">
                <%= if @editing_id do %>
                  Save changes
                <% else %>
                  Create location
                <% end %>
              </.button>

              <%= if @editing_id do %>
                <.button type="button" phx-click="cancel_edit" variant="outline">
                  Cancel
                </.button>
              <% end %>
            </div>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-accent p-6">
          <h2 class="text-sm font-semibold">Tips</h2>
          <ul class="mt-3 text-sm text-foreground space-y-2">
            <li>Print the QR code and post it where customers will see it.</li>
            <li>Use one location per physical site or area (e.g. locker room).</li>
            <li>Customers can optionally opt in to SMS updates.</li>
          </ul>
        </div>
      </div>

      <div class="overflow-x-auto">
        <.table>
          <.table_head>
            <:col>Location</:col>
            <:col>Reporter</:col>
            <:col>Poster</:col>
            <:col class="text-right"><span class="sr-only">Actions</span></:col>
          </.table_head>
          <.table_body>
            <.table_row :for={loc <- @locations}>
              <:cell>{loc.full_path || loc.name}</:cell>
              <:cell>
                <.button
                  href={loc.reporter_link}
                  target="_blank"
                  rel="noreferrer"
                  variant="ghost"
                  size="sm"
                >
                  Open link
                </.button>
              </:cell>
              <:cell>
                <.button
                  href={~p"/app/settings/locations/#{loc.id}/poster"}
                  target="_blank"
                  rel="noreferrer"
                  variant="ghost"
                  size="sm"
                >
                  Print / Save PDF
                </.button>
              </:cell>
              <:cell class="text-right">
                <.button_group>
                  <.button
                    type="button"
                    size="sm"
                    variant="outline"
                    phx-click="edit"
                    phx-value-id={loc.id}
                  >
                    Edit
                  </.button>
                </.button_group>
              </:cell>
            </.table_row>
          </.table_body>
        </.table>

        <div :if={@locations == []} class="py-10 text-center text-sm text-foreground-soft">
          No locations yet.
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.locations, &("#{&1.id}" == to_string(id))) do
      nil ->
        {:noreply, put_flash(socket, :error, "Location not found")}

      loc ->
        {:noreply,
         socket
         |> assign(:editing_id, loc.id)
         |> assign(:name, loc.name || "")
         |> assign(:full_path, loc.full_path || "")
         |> assign(:error, nil)}
    end
  end

  @impl true
  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_id, nil)
     |> assign(:name, "")
     |> assign(:full_path, "")
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("save", %{"name" => name} = params, socket) do
    tenant = socket.assigns.tenant

    name = String.trim(name || "")
    full_path = String.trim(Map.get(params, "full_path", "") || "")

    full_path =
      case full_path do
        "" -> nil
        v -> v
      end

    result =
      case socket.assigns.editing_id do
        nil ->
          Ash.create(Location, %{name: name, full_path: full_path}, tenant: tenant)

        id ->
          with {:ok, %Location{} = loc} <- Ash.get(Location, id, tenant: tenant) do
            Ash.update(loc, %{name: name, full_path: full_path}, action: :update, tenant: tenant)
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
       |> assign(:editing_id, nil)
       |> assign(:name, "")
       |> assign(:full_path, "")
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
