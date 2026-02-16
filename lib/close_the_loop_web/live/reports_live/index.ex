defmodule CloseTheLoopWeb.ReportsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Report
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:tenant, nil)
      |> assign(:reports, [])

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         {:ok, reports} <- list_reports(tenant) do
      {:ok, socket |> assign(:tenant, tenant) |> assign(:reports, reports)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load reports")}
    end
  end

  defp list_reports(tenant) do
    query =
      Report
      |> Ash.Query.load(issue: [:title], location: [:name, :full_path])
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(200)

    Ash.read(query, tenant: tenant)
  end

  defp report_excerpt(body) do
    body
    |> to_string()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.slice(0, 120)
  end

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  defp format_dt(other), do: to_string(other)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto">
      <div class="flex items-center justify-between gap-4">
        <h1 class="text-2xl font-semibold">Reports</h1>
        <.button navigate={~p"/app/reports/new"} variant="outline">New report</.button>
      </div>

      <%!-- Card list (no tables, no horizontal scrolling) --%>
      <div class="mt-6 rounded-2xl border border-base bg-base shadow-base overflow-hidden">
        <div :if={@reports == []} class="py-12 text-center text-sm text-foreground-soft">
          No reports yet.
        </div>

        <div :if={@reports != []} class="divide-y divide-base">
          <div
            :for={r <- @reports}
            id={"report-#{r.id}"}
            class={[
              "p-4 sm:p-5 transition",
              "hover:bg-accent"
            ]}
          >
            <div class="flex items-start gap-4">
              <div class="min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-2">
                  <.badge variant="soft" color="primary">{format_source(r.source)}</.badge>
                  <span class="text-xs text-foreground-soft whitespace-nowrap">
                    {format_dt(r.inserted_at)}
                  </span>
                </div>

                <p class="mt-2 text-sm font-medium text-foreground break-words">
                  {report_excerpt(r.body)}
                </p>

                <div class="mt-3 grid gap-1 text-xs text-foreground-soft">
                  <div class="flex items-start gap-2 min-w-0">
                    <.icon name="hero-map-pin" class="mt-0.5 size-4 shrink-0" />
                    <span class="truncate" title={r.location.full_path || r.location.name}>
                      {r.location.full_path || r.location.name}
                    </span>
                  </div>
                  <div class="flex items-start gap-2 min-w-0">
                    <.icon name="hero-inbox" class="mt-0.5 size-4 shrink-0" />
                    <span class="truncate" title={r.issue.title}>
                      {r.issue.title}
                    </span>
                  </div>
                </div>
              </div>

              <div class="shrink-0 flex flex-col items-end gap-2">
                <.button size="sm" variant="outline" navigate={~p"/app/reports/#{r.id}"}>
                  View
                </.button>
                <.button size="sm" variant="ghost" navigate={~p"/app/issues/#{r.issue_id}"}>
                  Issue
                </.button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_source(source) when is_atom(source),
    do: source |> Atom.to_string() |> String.upcase()

  defp format_source(source), do: source |> to_string() |> String.upcase()
end
