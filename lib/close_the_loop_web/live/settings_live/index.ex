defmodule CloseTheLoopWeb.SettingsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
      <div class="max-w-4xl mx-auto space-y-8">
        <div>
          <h1 class="text-2xl font-semibold">Settings</h1>
          <p class="mt-2 text-sm text-foreground-soft">
            Manage your organization, account, and issues configuration.
          </p>
        </div>

        <div class="grid gap-6 lg:grid-cols-3">
          <.link
            navigate={~p"/app/#{@current_org.id}/settings/organization"}
            class={[
              "block rounded-2xl border border-base bg-base p-6 shadow-base",
              "transition hover:bg-accent hover:shadow-lg hover:-translate-y-[1px]"
            ]}
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold">Organization</h2>
                <p class="mt-2 text-sm text-foreground-soft">
                  Name and reporter page branding.
                </p>
              </div>
              <.icon name="hero-building-office-2" class="size-5 text-foreground-soft" />
            </div>
          </.link>

          <.link
            :if={@current_role == :owner}
            navigate={~p"/app/#{@current_org.id}/settings/team"}
            class={[
              "block rounded-2xl border border-base bg-base p-6 shadow-base",
              "transition hover:bg-accent hover:shadow-lg hover:-translate-y-[1px]"
            ]}
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold">Team</h2>
                <p class="mt-2 text-sm text-foreground-soft">
                  Invite members and manage access.
                </p>
              </div>
              <.icon name="hero-users" class="size-5 text-foreground-soft" />
            </div>
          </.link>

          <.link
            navigate={~p"/app/#{@current_org.id}/settings/account"}
            class={[
              "block rounded-2xl border border-base bg-base p-6 shadow-base",
              "transition hover:bg-accent hover:shadow-lg hover:-translate-y-[1px]"
            ]}
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold">Account</h2>
                <p class="mt-2 text-sm text-foreground-soft">
                  Profile, email, password, sign out.
                </p>
              </div>
              <.icon name="hero-user-circle" class="size-5 text-foreground-soft" />
            </div>
          </.link>

          <.link
            navigate={~p"/app/#{@current_org.id}/settings/inbox"}
            class={[
              "block rounded-2xl border border-base bg-base p-6 shadow-base",
              "transition hover:bg-accent hover:shadow-lg hover:-translate-y-[1px]"
            ]}
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold">Issues configuration</h2>
                <p class="mt-2 text-sm text-foreground-soft">
                  Categories and triage settings.
                </p>
              </div>
              <.icon name="hero-adjustments-horizontal" class="size-5 text-foreground-soft" />
            </div>
          </.link>

          <.link
            navigate={~p"/app/#{@current_org.id}/settings/help"}
            class={[
              "block rounded-2xl border border-base bg-base p-6 shadow-base",
              "transition hover:bg-accent hover:shadow-lg hover:-translate-y-[1px]"
            ]}
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <h2 class="text-sm font-semibold">Help</h2>
                <p class="mt-2 text-sm text-foreground-soft">
                  How customers use the site and how features work.
                </p>
              </div>
              <.icon name="hero-question-mark-circle" class="size-5 text-foreground-soft" />
            </div>
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
