defmodule CloseTheLoopWeb.IssuesLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Issue
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         {:ok, issues} <- list_issues(tenant) do
      {:ok,
       socket
       |> assign(:tenant, tenant)
       |> assign(:issues, issues)}
    else
      _ ->
        {:ok, put_flash(socket, :error, "Failed to load issues")}
    end
  end

  defp list_issues(tenant) do
    query =
      Issue
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
        <table class="table table-zebra w-full">
          <thead>
            <tr>
              <th>Issue</th>
              <th>Location</th>
              <th>Category</th>
              <th>Status</th>
              <th class="text-right">Reporters</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <%= for issue <- @issues do %>
              <tr>
                <td class="font-medium">{issue.title}</td>
                <td>{issue.location.full_path || issue.location.name}</td>
                <td>
                  <%= if issue.category && issue.category != "" do %>
                    <span class="badge badge-ghost">{issue.category}</span>
                  <% else %>
                    <span class="text-base-content/50 text-sm">—</span>
                  <% end %>
                </td>
                <td>
                  <span class={"badge #{status_badge(issue.status)}"}>{issue.status}</span>
                </td>
                <td class="text-right">{issue.reporter_count}</td>
                <td class="text-right">
                  <.link class="btn btn-sm" navigate={~p"/app/issues/#{issue.id}"}>
                    View
                  </.link>
                </td>
              </tr>
            <% end %>
            <%= if @issues == [] do %>
              <tr>
                <td colspan="6" class="text-center text-base-content/60 py-8">
                  No issues yet.
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_badge(:new), do: "badge-info"
  defp status_badge(:acknowledged), do: "badge-warning"
  defp status_badge(:in_progress), do: "badge-warning"
  defp status_badge(:fixed), do: "badge-success"
  defp status_badge(_), do: "badge-ghost"
end
