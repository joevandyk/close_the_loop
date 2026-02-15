defmodule CloseTheLoopWeb.IssueCategoriesLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Feedback.IssueCategory
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, categories} <- list_categories(tenant) do
      {:ok,
       socket
       |> assign(:tenant, tenant)
       |> assign(:categories, categories)
       |> assign(:key, "")
       |> assign(:label, "")
       |> assign(:error, nil)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load categories")}
    end
  end

  defp list_categories(tenant) do
    query =
      IssueCategory
      |> Ash.Query.sort(active: :desc, key: :asc)

    Ash.read(query, tenant: tenant)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto space-y-8">
      <div class="flex items-start justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Issue categories</h1>
          <p class="mt-2 text-sm text-zinc-600">
            These categories are used by AI auto-classification and shown in your inbox.
          </p>
        </div>

        <.link class="btn" navigate={~p"/app/settings"}>Back</.link>
      </div>

      <div class="rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm">
        <h2 class="text-sm font-semibold">Add category</h2>

        <.form for={%{}} as={:category} phx-submit="create" class="mt-4 grid gap-4 sm:grid-cols-3">
          <div class="form-control sm:col-span-1">
            <label class="label" for="category_key">
              <span class="label-text">Key</span>
            </label>
            <input
              id="category_key"
              name="key"
              type="text"
              value={@key}
              class="input input-bordered w-full font-mono"
              placeholder="plumbing"
              required
            />
            <div class="mt-1 text-xs text-zinc-500">
              Lowercase letters/numbers/underscore only.
            </div>
          </div>

          <div class="form-control sm:col-span-2">
            <label class="label" for="category_label">
              <span class="label-text">Label</span>
            </label>
            <input
              id="category_label"
              name="label"
              type="text"
              value={@label}
              class="input input-bordered w-full"
              placeholder="Plumbing"
              required
            />
          </div>

          <div class="sm:col-span-3 flex items-center justify-between gap-3">
            <%= if @error do %>
              <div class="alert alert-error">
                <span>{@error}</span>
              </div>
            <% else %>
              <div />
            <% end %>

            <button type="submit" class="btn btn-primary">Add</button>
          </div>
        </.form>
      </div>

      <div class="rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm">
        <div class="flex items-center justify-between gap-4">
          <h2 class="text-sm font-semibold">Your categories</h2>
          <span class="text-xs text-zinc-500">Tenant: <span class="font-mono">{@tenant}</span></span>
        </div>

        <div class="mt-4 overflow-x-auto">
          <table class="table table-zebra w-full">
            <thead>
              <tr>
                <th>Key</th>
                <th>Label</th>
                <th>Status</th>
                <th class="text-right"></th>
              </tr>
            </thead>
            <tbody>
              <%= for cat <- @categories do %>
                <tr id={"category-#{cat.id}"}>
                  <td class="font-mono text-sm">{cat.key}</td>
                  <td class="font-medium">{cat.label}</td>
                  <td>
                    <%= if cat.active do %>
                      <span class="badge badge-success badge-outline">Active</span>
                    <% else %>
                      <span class="badge badge-ghost">Inactive</span>
                    <% end %>
                  </td>
                  <td class="text-right space-x-2">
                    <button
                      type="button"
                      class="btn btn-sm btn-outline"
                      phx-click="toggle_active"
                      phx-value-id={cat.id}
                    >
                      {if cat.active, do: "Deactivate", else: "Activate"}
                    </button>
                    <button
                      type="button"
                      class="btn btn-sm btn-ghost"
                      phx-click="delete"
                      phx-value-id={cat.id}
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              <% end %>

              <%= if @categories == [] do %>
                <tr>
                  <td colspan="4" class="text-center text-base-content/60 py-8">
                    No categories yet.
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("create", %{"key" => key, "label" => label}, socket) do
    tenant = socket.assigns.tenant
    key = key |> to_string() |> String.trim() |> String.downcase()
    label = label |> to_string() |> String.trim()

    with true <- key != "" || {:error, "Key is required"},
         true <-
           Regex.match?(~r/^[a-z0-9_]+$/, key) || {:error, "Key must be lowercase/underscore"},
         true <- label != "" || {:error, "Label is required"},
         {:ok, _cat} <-
           Ash.create(IssueCategory, %{key: key, label: label, active: true}, tenant: tenant),
         {:ok, categories} <- list_categories(tenant) do
      {:noreply,
       socket
       |> assign(:categories, categories)
       |> assign(:key, "")
       |> assign(:label, "")
       |> assign(:error, nil)
       |> put_flash(:info, "Category added.")}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, assign(socket, :error, msg)}

      {:error, err} ->
        {:noreply, assign(socket, :error, Exception.message(err))}

      other ->
        {:noreply, assign(socket, :error, "Failed to add: #{inspect(other)}")}
    end
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant

    with {:ok, %IssueCategory{} = cat} <- Ash.get(IssueCategory, id, tenant: tenant),
         {:ok, _} <- Ash.update(cat, %{active: not cat.active}, tenant: tenant),
         {:ok, categories} <- list_categories(tenant) do
      {:noreply, assign(socket, :categories, categories)}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to update category")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant = socket.assigns.tenant

    with {:ok, %IssueCategory{} = cat} <- Ash.get(IssueCategory, id, tenant: tenant),
         :ok <- Ash.destroy(cat, tenant: tenant),
         {:ok, categories} <- list_categories(tenant) do
      {:noreply, assign(socket, :categories, categories)}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to delete category")}
    end
  end
end
