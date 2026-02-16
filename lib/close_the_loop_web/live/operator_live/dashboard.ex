defmodule CloseTheLoopWeb.OperatorLive.Dashboard do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_admin_required}

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Tenants

  @impl true
  def mount(_params, _session, socket) do
    orgs = load_organizations()
    users = load_users()
    invitations = load_invitations()

    pending_invitations =
      Enum.filter(invitations, fn inv ->
        is_nil(inv.accepted_at) and is_nil(inv.revoked_at)
      end)

    socket =
      socket
      |> assign(:orgs, orgs)
      |> assign(:users, users)
      |> assign(:invitations, invitations)
      |> assign(:org_count, length(orgs))
      |> assign(:user_count, length(users))
      |> assign(:pending_invitation_count, length(pending_invitations))

    {:ok, socket}
  end

  defp load_organizations do
    case Tenants.list_organizations(authorize?: false) do
      {:ok, orgs} -> orgs
      _ -> []
    end
  end

  defp load_users do
    case Accounts.list_users(
           load: [:user_organizations],
           authorize?: false
         ) do
      {:ok, users} -> users
      _ -> []
    end
  end

  defp load_invitations do
    case Ash.read(
           CloseTheLoop.Accounts.OrganizationInvitation,
           authorize?: false,
           load: [:organization, :invited_by_user]
         ) do
      {:ok, invitations} -> invitations
      _ -> []
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
      <div class="max-w-5xl mx-auto space-y-8">
        <div>
          <h1 class="text-2xl font-semibold">Ops Dashboard</h1>
          <p class="mt-2 text-sm text-foreground-soft">
            Platform-wide overview for CloseTheLoop operators.
          </p>
        </div>

        <%!-- Summary cards --%>
        <div id="ops-stats" class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <.stat_card label="Organizations" value={@org_count} icon="hero-building-office-2" />
          <.stat_card label="Users" value={@user_count} icon="hero-users" />
          <.stat_card
            label="Pending Invitations"
            value={@pending_invitation_count}
            icon="hero-envelope"
          />
        </div>

        <%!-- Organizations --%>
        <section id="ops-organizations">
          <h2 class="text-lg font-semibold mb-3">Organizations</h2>
          <div class="rounded-2xl border border-base bg-base shadow-base overflow-hidden">
            <div :if={@orgs == []} class="py-12 text-center text-sm text-foreground-soft">
              No organizations yet.
            </div>

            <div :if={@orgs != []} class="divide-y divide-base">
              <.link
                :for={org <- @orgs}
                navigate={~p"/app/#{org.id}"}
                class="flex items-center justify-between gap-4 p-4 transition hover:bg-accent"
              >
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-semibold text-foreground">{org.name}</div>
                  <div class="mt-0.5 text-xs text-foreground-soft font-mono">
                    {org.tenant_schema}
                  </div>
                </div>
                <div class="shrink-0 text-right">
                  <div class="text-xs text-foreground-soft">
                    {format_date(org.inserted_at)}
                  </div>
                </div>
              </.link>
            </div>
          </div>
        </section>

        <%!-- Users --%>
        <section id="ops-users">
          <h2 class="text-lg font-semibold mb-3">Users</h2>
          <div class="rounded-2xl border border-base bg-base shadow-base overflow-hidden">
            <div :if={@users == []} class="py-12 text-center text-sm text-foreground-soft">
              No users yet.
            </div>

            <div :if={@users != []} class="divide-y divide-base">
              <div
                :for={user <- @users}
                class="flex items-center gap-4 p-4"
              >
                <div class="min-w-0 flex-1">
                  <div class="flex items-center gap-2">
                    <span class="text-sm font-semibold text-foreground">
                      {user.name || "—"}
                    </span>
                    <.badge :if={user.admin?} color="warning" size="xs">admin</.badge>
                    <.badge
                      :if={user.confirmed_at}
                      color="success"
                      size="xs"
                      variant="ghost"
                    >
                      confirmed
                    </.badge>
                    <.badge
                      :if={!user.confirmed_at}
                      color="danger"
                      size="xs"
                      variant="ghost"
                    >
                      unconfirmed
                    </.badge>
                  </div>
                  <div class="mt-0.5 text-xs text-foreground-soft">{user.email}</div>
                </div>
                <div class="shrink-0 text-right">
                  <div class="text-xs text-foreground-soft">
                    {length(user.user_organizations)} org(s)
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <%!-- Invitations --%>
        <section id="ops-invitations">
          <h2 class="text-lg font-semibold mb-3">Invitations</h2>
          <div class="rounded-2xl border border-base bg-base shadow-base overflow-hidden">
            <div :if={@invitations == []} class="py-12 text-center text-sm text-foreground-soft">
              No invitations yet.
            </div>

            <div :if={@invitations != []} class="divide-y divide-base">
              <div
                :for={inv <- @invitations}
                class="flex items-center gap-4 p-4"
              >
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-semibold text-foreground">{inv.email}</div>
                  <div class="mt-0.5 text-xs text-foreground-soft">
                    Org: {inv_org_name(inv)} &middot;
                    Invited by: {inv_invited_by(inv)} &middot;
                    Role: {inv.role}
                  </div>
                </div>
                <div class="shrink-0">
                  <.invitation_status_badge inv={inv} />
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base bg-base shadow-base p-5">
      <div class="flex items-center gap-3">
        <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-accent">
          <.icon name={@icon} class="size-5 text-foreground-soft" />
        </div>
        <div>
          <div class="text-2xl font-bold text-foreground">{@value}</div>
          <div class="text-xs text-foreground-soft">{@label}</div>
        </div>
      </div>
    </div>
    """
  end

  defp invitation_status_badge(assigns) do
    ~H"""
    <%= cond do %>
      <% @inv.accepted_at != nil -> %>
        <.badge color="success" size="xs">accepted</.badge>
      <% @inv.revoked_at != nil -> %>
        <.badge color="danger" size="xs">revoked</.badge>
      <% true -> %>
        <.badge color="info" size="xs">pending</.badge>
    <% end %>
    """
  end

  defp inv_org_name(inv) do
    case inv.organization do
      %{name: name} when is_binary(name) -> name
      _ -> "(unknown)"
    end
  end

  defp inv_invited_by(inv) do
    case inv.invited_by_user do
      %{email: email} when is_binary(email) -> email
      _ -> "(unknown)"
    end
  end

  defp format_date(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y")
  defp format_date(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y")
  defp format_date(_), do: "—"
end
