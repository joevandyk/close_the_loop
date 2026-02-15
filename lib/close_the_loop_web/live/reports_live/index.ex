defmodule CloseTheLoopWeb.ReportsLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Report
  alias CloseTheLoop.Tenants.Organization

  require Ash.Query

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

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto">
      <div class="flex items-center justify-between gap-4">
        <h1 class="text-2xl font-semibold">Reports</h1>
      </div>

      <div class="mt-6 overflow-x-auto">
        <.table>
          <.table_head>
            <:col>Report</:col>
            <:col>Location</:col>
            <:col>Issue</:col>
            <:col>Source</:col>
            <:col class="text-right">Received</:col>
            <:col class="text-right"><span class="sr-only">Actions</span></:col>
          </.table_head>

          <.table_body>
            <.table_row :for={r <- @reports}>
              <:cell>{String.slice(to_string(r.body), 0, 80)}</:cell>
              <:cell>{r.location.full_path || r.location.name}</:cell>
              <:cell>
                <.button navigate={~p"/app/issues/#{r.issue_id}"} variant="ghost" size="sm">
                  {r.issue.title}
                </.button>
              </:cell>
              <:cell>
                <.badge variant="soft" color="primary">{r.source}</.badge>
              </:cell>
              <:cell class="text-right text-sm text-foreground-soft">{r.inserted_at}</:cell>
              <:cell class="text-right">
                <.button size="sm" variant="outline" navigate={~p"/app/reports/#{r.id}"}>
                  View
                </.button>
              </:cell>
            </.table_row>
          </.table_body>
        </.table>

        <div :if={@reports == []} class="py-10 text-center text-sm text-foreground-soft">
          No reports yet.
        </div>
      </div>
    </div>
    """
  end
end
