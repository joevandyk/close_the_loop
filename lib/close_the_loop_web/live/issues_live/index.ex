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

      <%!-- Card list (no tables, no horizontal scrolling) --%>
      <div class="mt-6 rounded-2xl border border-base bg-base shadow-base overflow-hidden">
        <div :if={@issues == []} class="py-12 text-center text-sm text-foreground-soft">
          No issues yet.
        </div>

        <div :if={@issues != []} class="divide-y divide-base">
          <div
            :for={issue <- @issues}
            id={"issue-#{issue.id}"}
            class={[
              "p-4 sm:p-5 transition",
              "hover:bg-accent"
            ]}
          >
            <div class="flex items-start gap-4">
              <div class="min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-2">
                  <.badge variant="soft" color={status_color(issue.status)}>
                    {status_label(issue.status)}
                  </.badge>

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
                    <.badge variant="ghost" color="info">Uncategorized</.badge>
                  <% end %>

                  <span class="ml-auto inline-flex items-center gap-1 text-xs text-foreground-soft whitespace-nowrap">
                    <.icon name="hero-users" class="size-4" />
                    {issue.reporter_count}
                  </span>
                </div>

                <p class="mt-2 text-sm font-medium text-foreground break-words">
                  {issue.title}
                </p>

                <div class="mt-3 flex items-start gap-2 text-xs text-foreground-soft min-w-0">
                  <.icon name="hero-map-pin" class="mt-0.5 size-4 shrink-0" />
                  <span class="truncate" title={issue.location.full_path || issue.location.name}>
                    {issue.location.full_path || issue.location.name}
                  </span>
                </div>
              </div>

              <div class="shrink-0">
                <.button size="sm" variant="outline" navigate={~p"/app/issues/#{issue.id}"}>
                  View
                </.button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_label(status) when is_atom(status) do
    status
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp status_label(other), do: other |> to_string() |> String.capitalize()

  defp status_color(:new), do: "info"
  defp status_color(:acknowledged), do: "warning"
  defp status_color(:in_progress), do: "warning"
  defp status_color(:fixed), do: "success"
  defp status_color(_), do: "primary"
end
