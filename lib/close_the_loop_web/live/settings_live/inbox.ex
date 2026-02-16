defmodule CloseTheLoopWeb.SettingsLive.Inbox do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto space-y-8">
      <div class="flex items-start justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Inbox configuration</h1>
          <p class="mt-2 text-sm text-foreground-soft">
            Control how reports become issues and how your team triages them.
          </p>
        </div>

        <.button navigate={~p"/app/settings"} variant="ghost">Back</.button>
      </div>

      <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
        <h2 class="text-sm font-semibold">Issue categories</h2>
        <p class="mt-2 text-sm text-foreground-soft">
          Categories are used by AI auto-classification and shown in your inbox.
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
end
