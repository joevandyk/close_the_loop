defmodule CloseTheLoopWeb.DashboardLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Dashboard

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:stats, %{})
      |> assign(:recent_issues, [])
      |> assign(:recent_reports, [])
      |> assign(:recent_comments, [])
      |> assign(:recent_updates, [])

    tenant = socket.assigns.current_tenant

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, data} <- Dashboard.load(tenant) do
      {:ok,
       socket
       |> assign(:stats, data.stats)
       |> assign(:recent_issues, data.recent_issues)
       |> assign(:recent_reports, data.recent_reports)
       |> assign(:recent_comments, data.recent_comments)
       |> assign(:recent_updates, data.recent_updates)}
    else
      _ -> {:ok, put_flash(socket, :error, "Failed to load dashboard")}
    end
  end

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  defp format_dt(other), do: to_string(other)

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
      <div class="max-w-6xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Dashboard</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              A quick overview of what needs attention.
            </p>
          </div>

          <div class="flex items-center gap-2">
            <.button navigate={~p"/app/issues"} variant="outline">Open issues</.button>
            <.button navigate={~p"/app/reports/new"} variant="solid" color="primary">
              New report
            </.button>
          </div>
        </div>

        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <.stat_card title="Open issues" value={@stats.issues_total} hint="Excludes duplicates" />
          <.stat_card title="New" value={@stats.issues_new} hint="Needs triage" />
          <.stat_card title="In progress" value={@stats.issues_in_progress} hint="Work ongoing" />
          <.stat_card title="Fixed" value={@stats.issues_fixed} hint="Recently resolved" />
          <.stat_card title="Reports" value={@stats.reports_total} hint="All time" />
          <.stat_card title="Comments" value={@stats.comments_total} hint="Internal discussion" />
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <.list_panel title="Recent issues" empty_text="No issues yet.">
            <div :for={i <- @recent_issues} id={"dash-issue-#{i.id}"} class="py-3">
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <.link
                    navigate={~p"/app/issues/#{i.id}"}
                    class="text-sm font-medium hover:underline"
                  >
                    {i.title}
                  </.link>
                  <div class="mt-1 flex items-center gap-2 text-xs text-foreground-soft min-w-0">
                    <.icon name="hero-map-pin" class="size-4 shrink-0" />
                    <span class="truncate">{i.location.full_path || i.location.name}</span>
                    <span class="ml-auto inline-flex items-center gap-1 whitespace-nowrap">
                      <.icon name="hero-users" class="size-4" />
                      {i.reporter_count}
                    </span>
                  </div>
                </div>
                <.button size="sm" variant="outline" navigate={~p"/app/issues/#{i.id}"}>View</.button>
              </div>
            </div>
          </.list_panel>

          <.list_panel title="Recent reports" empty_text="No reports yet.">
            <div :for={r <- @recent_reports} id={"dash-report-#{r.id}"} class="py-3">
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <.link
                    navigate={~p"/app/reports/#{r.id}"}
                    class="text-sm font-medium hover:underline"
                  >
                    {r.body |> to_string() |> String.slice(0, 70)}
                  </.link>
                  <div class="mt-1 flex items-center gap-2 text-xs text-foreground-soft min-w-0">
                    <.icon name="hero-map-pin" class="size-4 shrink-0" />
                    <span class="truncate">{r.location.full_path || r.location.name}</span>
                  </div>
                  <div class="mt-1 flex items-center gap-2 text-xs text-foreground-soft min-w-0">
                    <.icon name="hero-inbox" class="size-4 shrink-0" />
                    <span class="truncate">{r.issue.title}</span>
                    <span class="ml-auto whitespace-nowrap">{format_dt(r.inserted_at)}</span>
                  </div>
                </div>
                <.button size="sm" variant="outline" navigate={~p"/app/reports/#{r.id}"}>
                  View
                </.button>
              </div>
            </div>
          </.list_panel>
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <.list_panel title="Recent comments" empty_text="No comments yet.">
            <div :for={c <- @recent_comments} id={"dash-comment-#{c.id}"} class="py-3">
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <div class="text-xs text-foreground-soft">
                    <span class="font-medium text-foreground">{c.author_email || "Internal"}</span>
                    <span class="mx-1 opacity-60">•</span>
                    <span>{format_dt(c.inserted_at)}</span>
                  </div>
                  <div class="mt-1 text-sm text-foreground break-words">
                    {c.body}
                  </div>
                  <div class="mt-1 text-xs text-foreground-soft">
                    On:
                    <.link navigate={~p"/app/issues/#{c.issue_id}"} class="hover:underline">
                      {c.issue.title}
                    </.link>
                  </div>
                </div>
              </div>
            </div>
          </.list_panel>

          <.list_panel title="Recent updates" empty_text="No updates yet.">
            <div :for={u <- @recent_updates} id={"dash-update-#{u.id}"} class="py-3">
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <div class="text-xs text-foreground-soft">
                    <span class="font-medium text-foreground">Update queued</span>
                    <span class="mx-1 opacity-60">•</span>
                    <span>{format_dt(u.inserted_at)}</span>
                  </div>
                  <div class="mt-1 text-sm text-foreground break-words">
                    {u.message}
                  </div>
                  <div class="mt-1 text-xs text-foreground-soft">
                    For:
                    <.link navigate={~p"/app/issues/#{u.issue_id}"} class="hover:underline">
                      {u.issue.title}
                    </.link>
                  </div>
                </div>
              </div>
            </div>
          </.list_panel>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :hint, :string, required: true

  defp stat_card(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base bg-base p-5 shadow-base">
      <div class="flex items-center justify-between gap-3">
        <p class="text-sm font-medium text-foreground-soft">{@title}</p>
      </div>
      <p class="mt-2 text-3xl font-semibold tracking-tight">{@value}</p>
      <p class="mt-1 text-xs text-foreground-soft">{@hint}</p>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :empty_text, :string, required: true
  slot :inner_block, required: true

  defp list_panel(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base bg-base shadow-base overflow-hidden">
      <div class="flex items-center justify-between gap-4 border-b border-base px-5 py-4">
        <h2 class="text-sm font-semibold">{@title}</h2>
      </div>
      <div class="px-5 divide-y divide-base">
        <div class="py-10 text-center text-sm text-foreground-soft hidden only:block">
          {@empty_text}
        </div>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
