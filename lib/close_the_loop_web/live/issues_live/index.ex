defmodule CloseTheLoopWeb.IssuesLive.Index do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Categories
  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:issues, [])
      |> assign(:q, nil)
      |> assign(:status, nil)
      |> assign(:filters_form, to_form(%{"q" => ""}, as: :filters))
      |> assign(:category_labels, %{})
      |> assign(:active_category_labels, %{})

    tenant = socket.assigns.current_tenant

    if is_binary(tenant) do
      with :ok <- Categories.ensure_defaults(tenant) do
        {:ok,
         socket
         |> assign(:category_labels, Categories.key_label_map(tenant))
         |> assign(:active_category_labels, Categories.active_key_label_map(tenant))}
      else
        _ ->
          {:ok, put_flash(socket, :error, "Failed to load issues")}
      end
    else
      {:ok, put_flash(socket, :error, "Failed to load issues")}
    end
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tenant = socket.assigns.current_tenant
    status = parse_status(params["status"])
    q = parse_q(params["q"])

    socket =
      socket
      |> assign(:status, status)
      |> assign(:q, q)
      |> assign(:filters_form, to_form(%{"q" => q || ""}, as: :filters))

    case list_issues(tenant, status, q) do
      {:ok, issues} ->
        {:noreply, assign(socket, :issues, issues)}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to load issues")}
    end
  end

  @impl true
  def handle_event("filters_changed", %{"filters" => %{"q" => q}}, socket) do
    q = q |> to_string() |> String.trim()
    q = if q == "", do: nil, else: q

    {:noreply,
     push_patch(socket,
       to: issues_index_path(socket.assigns.current_org.id, socket.assigns.status, q)
     )}
  end

  def handle_event("clear_search", _params, socket) do
    {:noreply,
     push_patch(socket,
       to: issues_index_path(socket.assigns.current_org.id, socket.assigns.status, nil)
     )}
  end

  defp list_issues(tenant, status, q) when is_binary(tenant) do
    query =
      CloseTheLoop.Feedback.Issue
      |> Ash.Query.for_read(:non_duplicates, %{})
      |> Ash.Query.sort(inserted_at: :desc)

    query =
      if status do
        Ash.Query.filter(query, status == ^status)
      else
        query
      end

    query =
      if q do
        Ash.Query.filter(query, contains(title, ^q) or contains(description, ^q))
      else
        query
      end

    CloseTheLoop.Feedback.list_non_duplicate_issues(
      tenant: tenant,
      query: query,
      load: [:reporter_count, location: [:name, :full_path]]
    )
  end

  defp list_issues(_tenant, _status, _q), do: {:ok, []}

  defp issues_index_path(org_id, status, q) do
    params =
      %{}
      |> maybe_put(:status, status && Atom.to_string(status))
      |> maybe_put(:q, q)

    ~p"/app/#{org_id}/issues?#{params}"
  end

  defp maybe_put(params, _key, nil), do: params
  defp maybe_put(params, key, value), do: Map.put(params, key, value)

  defp parse_status(nil), do: nil

  defp parse_status(status) when status in ["new", "acknowledged", "in_progress", "fixed"] do
    String.to_existing_atom(status)
  end

  defp parse_status(_), do: nil

  defp parse_q(nil), do: nil

  defp parse_q(q) do
    q = q |> to_string() |> String.trim()
    if q == "", do: nil, else: q
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
      <div class="max-w-5xl mx-auto">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 class="text-2xl font-semibold">Issues</h1>
            <p class="mt-2 text-sm text-foreground-soft">
              Filter by status, search, and click into an issue to take action.
            </p>
          </div>

          <div class="flex items-center gap-2">
            <.form for={@filters_form} id="issues-filters-form" phx-change="filters_changed">
              <.input
                field={@filters_form[:q]}
                type="search"
                placeholder="Search issues..."
                phx-debounce="300"
              >
                <:inner_prefix>
                  <.icon name="hero-magnifying-glass" class="icon" />
                </:inner_prefix>
                <:inner_suffix :if={@q}>
                  <.button
                    type="button"
                    size="icon-sm"
                    variant="ghost"
                    phx-click="clear_search"
                    aria-label="Clear search"
                  >
                    <.icon name="hero-x-mark" class="icon" />
                  </.button>
                </:inner_suffix>
              </.input>
            </.form>
          </div>
        </div>

        <div class="mt-5 flex flex-wrap items-center gap-2">
          <.link
            patch={issues_index_path(@current_org.id, nil, @q)}
            class={status_pill_class(@status == nil)}
            id="issues-status-all"
          >
            All
          </.link>
          <.link
            patch={issues_index_path(@current_org.id, :new, @q)}
            class={status_pill_class(@status == :new)}
            id="issues-status-new"
          >
            New
          </.link>
          <.link
            patch={issues_index_path(@current_org.id, :acknowledged, @q)}
            class={status_pill_class(@status == :acknowledged)}
            id="issues-status-acknowledged"
          >
            Acknowledged
          </.link>
          <.link
            patch={issues_index_path(@current_org.id, :in_progress, @q)}
            class={status_pill_class(@status == :in_progress)}
            id="issues-status-in-progress"
          >
            In progress
          </.link>
          <.link
            patch={issues_index_path(@current_org.id, :fixed, @q)}
            class={status_pill_class(@status == :fixed)}
            id="issues-status-fixed"
          >
            Fixed
          </.link>
        </div>

        <%!-- Card list (no tables, no horizontal scrolling) --%>
        <div
          id="issues-list"
          class="mt-6 rounded-2xl border border-base bg-base shadow-base overflow-hidden"
        >
          <div :if={@issues == []} class="py-12 text-center text-sm text-foreground-soft">
            No issues yet.
          </div>

          <div :if={@issues != []} class="divide-y divide-base">
            <.link
              :for={issue <- @issues}
              id={"issue-#{issue.id}"}
              navigate={~p"/app/#{@current_org.id}/issues/#{issue.id}"}
              class={[
                "block p-4 sm:p-5 transition cursor-pointer",
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
              </div>
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
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

  defp status_pill_class(active?) do
    [
      "inline-flex items-center rounded-full px-3 py-1 text-xs font-medium transition",
      "border border-base",
      if(active?,
        do: "bg-foreground text-background hover:opacity-90",
        else: "bg-base text-foreground hover:bg-accent"
      )
    ]
  end
end
