defmodule CloseTheLoopWeb.OrgPickerLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_user_required}

  alias CloseTheLoop.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:memberships, [])
      |> assign(:error, nil)

    case Accounts.list_user_organizations(
           query: [filter: [user_id: user.id], sort: [inserted_at: :desc], limit: 50],
           load: [organization: [:name, :tenant_schema]],
           authorize?: false
         ) do
      {:ok, []} ->
        {:ok, push_navigate(socket, to: ~p"/app/onboarding")}

      {:ok, memberships} ->
        {:ok, assign(socket, :memberships, memberships)}

      {:error, err} ->
        {:ok, assign(socket, :error, Exception.message(err))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
      <div class="max-w-3xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Organizations</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Choose the organization you want to manage.
            </p>
          </div>

          <.button navigate={~p"/app/organizations/new"} variant="solid" color="primary">
            New organization
          </.button>
        </div>

        <.alert :if={@error} color="danger" hide_close>
          {@error}
        </.alert>

        <div class="rounded-2xl border border-base bg-base shadow-base overflow-hidden">
          <div :if={@memberships == []} class="py-12 text-center text-sm text-foreground-soft">
            You aren't a member of any organizations yet.
            <div class="mt-4">
              <.button navigate={~p"/app/onboarding"} variant="outline">Create one</.button>
            </div>
          </div>

          <.navlist
            :if={@memberships != []}
            class="divide-y divide-base space-y-0 rounded-2xl border-0 p-0 [&+[data-part=navlist]]:mt-0"
          >
            <.navlink
              :for={m <- @memberships}
              id={"org-#{m.organization_id}"}
              navigate={~p"/app/#{m.organization_id}"}
              class="ml-0 px-4 py-3 rounded-none first:rounded-t-2xl last:rounded-b-2xl"
            >
              <div class="min-w-0 flex-1">
                <div class="text-sm font-semibold text-foreground">
                  {m.organization.name}
                </div>
                <div class="mt-0.5 text-xs text-foreground-soft">
                  Role: {m.role}
                </div>
              </div>
              <span class="ml-auto shrink-0 text-sm font-medium text-foreground-soft">
                Open
              </span>
            </.navlink>
          </.navlist>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
