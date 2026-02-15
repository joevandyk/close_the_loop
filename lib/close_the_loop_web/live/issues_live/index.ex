defmodule CloseTheLoopWeb.IssuesLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  import Ash.Expr

  alias CloseTheLoop.Feedback.Issue
  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Tenants.Organization

  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:tenant, nil)
      |> assign(:issues, [])
      |> assign(:category_labels, %{})
      |> assign(:active_category_labels, %{})

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, issues} <- list_issues(tenant) do
      {:ok,
       socket
       |> assign(:tenant, tenant)
       |> assign(:issues, issues)
       |> assign(:category_labels, Categories.key_label_map(tenant))
       |> assign(:active_category_labels, Categories.active_key_label_map(tenant))}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load issues")}
    end
  end

  defp list_issues(tenant) do
    query =
      Issue
      |> Ash.Query.filter(expr(is_nil(duplicate_of_issue_id)))
      |> Ash.Query.load([:reporter_count, location: [:name, :full_path]])
      |> Ash.Query.sort(inserted_at: :desc)

    Ash.read(query, tenant: tenant)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto">
      <div class="flex items-center justify-between gap-4">
        <h1 class="text-2xl font-semibold">Inbox</h1>
      </div>

      <div class="mt-6 overflow-x-auto">
        <.table>
          <.table_head>
            <:col>Issue</:col>
            <:col>Location</:col>
            <:col>Category</:col>
            <:col>Status</:col>
            <:col class="text-right">Reporters</:col>
            <:col class="text-right"><span class="sr-only">Actions</span></:col>
          </.table_head>

          <.table_body>
            <.table_row :for={issue <- @issues}>
              <:cell class="font-medium">{issue.title}</:cell>
              <:cell>{issue.location.full_path || issue.location.name}</:cell>
              <:cell>
                <%= if issue.category && issue.category != "" do %>
                  <% key = issue.category %>
                  <% label = Map.get(@category_labels, key, key) %>
                  <% active? = Map.has_key?(@active_category_labels, key) %>

                  <.badge
                    variant={if(active?, do: "surface", else: "ghost")}
                    color={if(active?, do: "primary", else: "warning")}
                    title={
                      if(active?,
                        do: nil,
                        else: "This category is inactive (kept for existing issues)."
                      )
                    }
                  >
                    {label}
                    <span :if={!active?} class="ml-1 text-[10px] opacity-80">(inactive)</span>
                  </.badge>
                <% else %>
                  <span class="text-sm text-foreground-soft">—</span>
                <% end %>
              </:cell>
              <:cell>
                <.badge variant="soft" color={status_color(issue.status)}>
                  {issue.status}
                </.badge>
              </:cell>
              <:cell class="text-right">{issue.reporter_count}</:cell>
              <:cell class="text-right">
                <.button size="sm" variant="outline" navigate={~p"/app/issues/#{issue.id}"}>
                  View
                </.button>
              </:cell>
            </.table_row>
          </.table_body>
        </.table>

        <div :if={@issues == []} class="py-10 text-center text-sm text-foreground-soft">
          No issues yet.
        </div>
      </div>
    </div>
    """
  end

  defp status_color(:new), do: "info"
  defp status_color(:acknowledged), do: "warning"
  defp status_color(:in_progress), do: "warning"
  defp status_color(:fixed), do: "success"
  defp status_color(_), do: "primary"
end
