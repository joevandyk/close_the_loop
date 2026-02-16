defmodule CloseTheLoopWeb.DashboardLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback, as: FeedbackDomain
  alias CloseTheLoop.Feedback.Dashboard
  alias CloseTheLoopWeb.OnboardingProgress

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:stats, %{})
      |> assign(:recent_issues, [])
      |> assign(:recent_reports, [])
      |> assign(:recent_comments, [])
      |> assign(:recent_updates, [])
      |> assign(:getting_started, nil)

    tenant = socket.assigns.current_tenant
    org = socket.assigns.current_org

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, data} <- Dashboard.load(tenant) do
      progress = socket.assigns[:onboarding_progress] || OnboardingProgress.load(tenant)

      primary_location =
        case FeedbackDomain.list_locations(
               tenant: tenant,
               query: [sort: [inserted_at: :asc], limit: 1]
             ) do
          {:ok, [loc | _]} -> loc
          _ -> nil
        end

      reporter_link =
        if primary_location do
          CloseTheLoopWeb.Endpoint.url() <> "/r/#{tenant}/#{primary_location.id}"
        end

      poster_href =
        if primary_location do
          ~p"/app/#{org.id}/settings/locations/#{primary_location.id}/poster"
        end

      getting_started = %{
        show?: Map.get(progress, :complete?) == false,
        progress: progress,
        onboarding_href: ~p"/app/#{org.id}/onboarding",
        poster_href: poster_href,
        reporter_link: reporter_link
      }

      {:ok,
       socket
       |> assign(:stats, data.stats)
       |> assign(:recent_issues, data.recent_issues)
       |> assign(:recent_reports, data.recent_reports)
       |> assign(:recent_comments, data.recent_comments)
       |> assign(:recent_updates, data.recent_updates)
       |> assign(:getting_started, getting_started)}
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
    <Layouts.app
      flash={@flash}
      current_user={@current_user}
      current_scope={@current_scope}
      org={@current_org}
    >
      <div class="max-w-6xl mx-auto space-y-8">
        <div class="flex items-start justify-between gap-4">
          <div>
            <h1 class="text-2xl font-semibold">Dashboard</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              A quick overview of what needs attention.
            </p>
          </div>

          <div class="flex items-center gap-2">
            <.button navigate={~p"/app/#{@current_org.id}/issues"} variant="outline">
              Open issues
            </.button>
            <.button
              navigate={~p"/app/#{@current_org.id}/reports/new"}
              variant="solid"
              color="primary"
            >
              New report
            </.button>
          </div>
        </div>

        <div
          :if={@getting_started && @getting_started.show?}
          class="rounded-2xl border border-base bg-base p-5 shadow-base"
        >
          <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div class="min-w-0">
              <h2 class="text-sm font-semibold flex items-center gap-2">
                <.icon name="hero-sparkles" class="size-4 text-foreground-soft" /> Getting started
              </h2>
              <p class="mt-1 text-sm text-foreground-soft">
                <%= if @getting_started.progress.has_any_locations? do %>
                  Print a poster and submit a test report to validate the full loop.
                <% else %>
                  Add your first location to unlock posters and reporter links.
                <% end %>
              </p>
            </div>

            <div class="flex flex-wrap items-center gap-2 shrink-0">
              <.button
                :if={@getting_started.poster_href}
                href={@getting_started.poster_href}
                target="_blank"
                rel="noreferrer"
                variant="solid"
                color="primary"
              >
                <.icon name="hero-printer" class="size-4" /> Print poster
              </.button>

              <.button
                :if={@getting_started.reporter_link}
                href={@getting_started.reporter_link}
                target="_blank"
                rel="noreferrer"
                variant="outline"
              >
                <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Submit test report
              </.button>

              <.button navigate={@getting_started.onboarding_href} variant="outline">
                View checklist
              </.button>
            </div>
          </div>
        </div>

        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <.stat_card
            title="Open issues"
            value={@stats.issues_total}
            hint="Active"
            navigate={~p"/app/#{@current_org.id}/issues"}
          />
          <.stat_card
            title="New"
            value={@stats.issues_new}
            hint="Needs triage"
            navigate={~p"/app/#{@current_org.id}/issues?#{%{status: "new"}}"}
          />
          <.stat_card
            title="In progress"
            value={@stats.issues_in_progress}
            hint="Work ongoing"
            navigate={~p"/app/#{@current_org.id}/issues?#{%{status: "in_progress"}}"}
          />
          <.stat_card
            title="Fixed"
            value={@stats.issues_fixed}
            hint="Recently resolved"
            navigate={~p"/app/#{@current_org.id}/issues?#{%{status: "fixed"}}"}
          />
          <.stat_card
            title="Reports"
            value={@stats.reports_total}
            hint="All time"
            navigate={~p"/app/#{@current_org.id}/reports"}
          />
          <.stat_card title="Comments" value={@stats.comments_total} hint="Internal discussion" />
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <.list_panel title="Recent issues" empty_text="No issues yet.">
            <.link
              :for={i <- @recent_issues}
              id={"dash-issue-#{i.id}"}
              navigate={~p"/app/#{@current_org.id}/issues/#{i.id}"}
              aria-label={"View issue: #{i.title}"}
              class={[
                "block py-3 -mx-2 px-2 rounded-xl",
                "transition hover:bg-accent/60 hover:shadow-sm",
                "focus-visible:outline-hidden focus-visible:ring-3 focus-visible:ring-focus"
              ]}
            >
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-medium text-foreground line-clamp-2">
                    {i.title}
                  </div>
                  <div class="mt-1 flex items-center gap-2 text-xs text-foreground-soft min-w-0">
                    <.icon name="hero-map-pin" class="size-4 shrink-0" />
                    <span class="min-w-0 line-clamp-2">
                      {i.location.full_path || i.location.name}
                    </span>
                    <span class="inline-flex items-center gap-1 whitespace-nowrap shrink-0">
                      <.icon name="hero-users" class="size-4" />
                      {i.reporter_count}
                    </span>
                    <time
                      id={"dash-issue-time-#{i.id}"}
                      phx-hook="LocalTime"
                      data-iso={iso8601(i.inserted_at)}
                      class="ml-auto shrink-0 whitespace-nowrap"
                    >
                      {format_dt(i.inserted_at)}
                    </time>
                  </div>
                </div>

                <.icon name="hero-chevron-right" class="mt-0.5 size-4 shrink-0 text-foreground-soft" />
              </div>
            </.link>
          </.list_panel>

          <.list_panel title="Recent reports" empty_text="No reports yet.">
            <.link
              :for={r <- @recent_reports}
              id={"dash-report-#{r.id}"}
              navigate={~p"/app/#{@current_org.id}/reports/#{r.id}"}
              aria-label={"View report: #{r.body |> to_string() |> String.slice(0, 80)}"}
              class={[
                "block py-3 -mx-2 px-2 rounded-xl",
                "transition hover:bg-accent/60 hover:shadow-sm",
                "focus-visible:outline-hidden focus-visible:ring-3 focus-visible:ring-focus"
              ]}
            >
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <div class="text-sm font-medium text-foreground line-clamp-2">
                    {r.body |> to_string()}
                  </div>
                  <div class="mt-1 flex items-center gap-2 text-xs text-foreground-soft min-w-0">
                    <.icon name="hero-map-pin" class="size-4 shrink-0" />
                    <span class="min-w-0 line-clamp-2">
                      {r.location.full_path || r.location.name}
                    </span>
                    <time
                      id={"dash-report-time-#{r.id}"}
                      phx-hook="LocalTime"
                      data-iso={iso8601(r.inserted_at)}
                      class="ml-auto shrink-0 whitespace-nowrap"
                    >
                      {format_dt(r.inserted_at)}
                    </time>
                  </div>
                </div>

                <.icon name="hero-chevron-right" class="mt-0.5 size-4 shrink-0 text-foreground-soft" />
              </div>
            </.link>
          </.list_panel>
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <.list_panel title="Recent comments" empty_text="No comments yet.">
            <.link
              :for={c <- @recent_comments}
              id={"dash-comment-#{c.id}"}
              navigate={~p"/app/#{@current_org.id}/issues/#{c.issue_id}"}
              aria-label={"View issue: #{c.issue.title}"}
              class={[
                "block py-3 -mx-2 px-2 rounded-xl",
                "transition hover:bg-accent/60 hover:shadow-sm",
                "focus-visible:outline-hidden focus-visible:ring-3 focus-visible:ring-focus"
              ]}
            >
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <div class="text-xs text-foreground-soft">
                    <span class="font-medium text-foreground">{c.author_email || "Internal"}</span>
                    <span class="mx-1 opacity-60">•</span>
                    <time
                      id={"dash-comment-time-#{c.id}"}
                      phx-hook="LocalTime"
                      data-iso={iso8601(c.inserted_at)}
                    >
                      {format_dt(c.inserted_at)}
                    </time>
                  </div>
                  <div class="mt-1 text-sm text-foreground line-clamp-2">
                    {c.body}
                  </div>
                  <div class="mt-1 text-xs text-foreground-soft line-clamp-1">
                    On: <span class="font-medium text-foreground">{c.issue.title}</span>
                  </div>
                </div>

                <.icon name="hero-chevron-right" class="mt-0.5 size-4 shrink-0 text-foreground-soft" />
              </div>
            </.link>
          </.list_panel>

          <.list_panel title="Recent updates" empty_text="No updates yet.">
            <.link
              :for={u <- @recent_updates}
              id={"dash-update-#{u.id}"}
              navigate={~p"/app/#{@current_org.id}/issues/#{u.issue_id}"}
              aria-label={"View issue: #{u.issue.title}"}
              class={[
                "block py-3 -mx-2 px-2 rounded-xl",
                "transition hover:bg-accent/60 hover:shadow-sm",
                "focus-visible:outline-hidden focus-visible:ring-3 focus-visible:ring-focus"
              ]}
            >
              <div class="flex items-start gap-3">
                <div class="min-w-0 flex-1">
                  <div class="text-xs text-foreground-soft">
                    <span class="font-medium text-foreground">Update queued</span>
                    <span class="mx-1 opacity-60">•</span>
                    <time
                      id={"dash-update-time-#{u.id}"}
                      phx-hook="LocalTime"
                      data-iso={iso8601(u.inserted_at)}
                    >
                      {format_dt(u.inserted_at)}
                    </time>
                  </div>
                  <div class="mt-1 text-sm text-foreground line-clamp-2">
                    {u.message}
                  </div>
                  <div class="mt-1 text-xs text-foreground-soft line-clamp-1">
                    For: <span class="font-medium text-foreground">{u.issue.title}</span>
                  </div>
                </div>

                <.icon name="hero-chevron-right" class="mt-0.5 size-4 shrink-0 text-foreground-soft" />
              </div>
            </.link>
          </.list_panel>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :hint, :string, required: true
  attr :navigate, :string, default: nil

  defp stat_card(assigns) do
    ~H"""
    <.link
      :if={@navigate}
      navigate={@navigate}
      class={[
        "block rounded-2xl border border-base bg-base p-5 shadow-base",
        "transition hover:bg-accent hover:shadow-lg hover:-translate-y-[1px]"
      ]}
    >
      <div class="flex items-center justify-between gap-3">
        <p class="text-sm font-medium text-foreground-soft">{@title}</p>
        <.icon name="hero-arrow-right" class="size-4 text-foreground-soft" />
      </div>
      <p class="mt-2 text-3xl font-semibold tracking-tight">{@value}</p>
      <p class="mt-1 text-xs text-foreground-soft">{@hint}</p>
    </.link>

    <div :if={!@navigate} class="rounded-2xl border border-base bg-base p-5 shadow-base">
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
