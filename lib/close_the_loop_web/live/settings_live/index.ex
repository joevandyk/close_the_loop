defmodule CloseTheLoopWeb.SettingsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    case Ash.get(Organization, user.organization_id) do
      {:ok, %Organization{} = org} ->
        {:ok,
         socket
         |> assign(:org, org)
         |> assign(:tenant, org.tenant_schema)
         |> assign(:org_name, org.name)
         |> assign(:error, nil)}

      _ ->
        {:ok, put_flash(socket, :error, "Failed to load settings")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto space-y-8">
      <div>
        <h1 class="text-2xl font-semibold">Settings</h1>
        <p class="mt-2 text-sm text-foreground-soft">
          Manage your organization and account.
        </p>
      </div>

      <div class="grid gap-6 lg:grid-cols-2">
        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Organization</h2>

          <.form for={%{}} as={:org} phx-submit="save_org" class="mt-4 space-y-4">
            <.input id="org_name" name="name" type="text" label="Name" value={@org_name} required />

            <div class="text-xs text-zinc-500">
              Tenant: <span class="font-mono">{@tenant}</span>
            </div>

            <%= if @error do %>
              <.alert color="danger" hide_close>{@error}</.alert>
            <% end %>

            <.button type="submit" variant="solid" color="primary" class="w-full">Save</.button>
          </.form>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Account</h2>

          <dl class="mt-4 space-y-3 text-sm">
            <div class="flex items-center justify-between gap-4">
              <dt class="text-foreground-soft">Email</dt>
              <dd class="font-medium">{@current_user.email}</dd>
            </div>
            <div class="flex items-center justify-between gap-4">
              <dt class="text-foreground-soft">Role</dt>
              <dd class="font-medium">{@current_user.role || :staff}</dd>
            </div>
          </dl>

          <div class="mt-6">
            <.button href={~p"/sign-out"} variant="outline" class="w-full">
              Sign out
            </.button>
          </div>
        </div>
      </div>

      <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
        <h2 class="text-sm font-semibold">Inbox configuration</h2>
        <p class="mt-2 text-sm text-foreground-soft">
          Control AI-driven issue categorization labels for your business.
        </p>

        <div class="mt-4">
          <.button navigate={~p"/app/settings/issue-categories"} variant="outline">
            Manage issue categories
          </.button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("save_org", %{"name" => name}, socket) do
    org = socket.assigns.org
    name = String.trim(name || "")

    with true <- name != "" || {:error, "Name is required"},
         {:ok, %Organization{} = org} <- Ash.update(org, %{name: name}) do
      {:noreply,
       socket
       |> put_flash(:info, "Settings saved.")
       |> assign(:org, org)
       |> assign(:org_name, org.name)
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
