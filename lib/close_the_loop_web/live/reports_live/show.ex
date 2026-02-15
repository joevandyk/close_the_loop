defmodule CloseTheLoopWeb.ReportsLive.Show do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  import Ash.Expr

  alias CloseTheLoop.Feedback.{Issue, IssueComment, Report}
  alias CloseTheLoop.Tenants.Organization

  require Ash.Query

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:tenant, nil)
      |> assign(:report, nil)
      |> assign(:issue_options, [])
      |> assign(:new_issue_open?, false)
      |> assign(:new_issue_title, "")

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         {:ok, report} <- get_report(tenant, id),
         {:ok, issues} <- list_issue_options(tenant, report.location_id, report.issue_id) do
      {:ok,
       socket
       |> assign(:tenant, tenant)
       |> assign(:report, report)
       |> assign(:issue_options, build_issue_options(issues))
       |> assign(:new_issue_title, default_issue_title(report.body))}
    else
      _ ->
        {:ok,
         put_flash(socket, :error, "Report not found") |> push_navigate(to: ~p"/app/reports")}
    end
  end

  defp get_report(tenant, id) do
    Ash.get(Report, id,
      tenant: tenant,
      load: [issue: [:title, :status], location: [:name, :full_path]]
    )
  end

  defp list_issue_options(tenant, location_id, current_issue_id) do
    query =
      Issue
      |> Ash.Query.filter(
        expr(
          location_id == ^location_id and is_nil(duplicate_of_issue_id) and
            id != ^current_issue_id
        )
      )
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(100)

    Ash.read(query, tenant: tenant)
  end

  defp build_issue_options(issues) do
    Enum.map(issues, fn issue ->
      {"#{issue.title} (#{issue.status})", issue.id}
    end)
  end

  defp default_issue_title(body) do
    body
    |> to_string()
    |> String.trim()
    |> String.slice(0, 80)
    |> case do
      "" -> "New issue"
      title -> title
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto space-y-6">
      <div class="flex items-start justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">Report</h1>
          <div class="mt-1 text-sm text-foreground-soft">
            <span>Location:</span>
            <span class="font-medium text-foreground">
              {@report.location.full_path || @report.location.name}
            </span>
            <span class="mx-2">•</span>
            <span>Source: {@report.source}</span>
            <span class="mx-2">•</span>
            <span>{@report.inserted_at}</span>
          </div>
        </div>

        <div class="flex items-center gap-2">
          <.button navigate={~p"/app/reports"} variant="ghost">Back</.button>
          <.button navigate={~p"/app/issues/#{@report.issue_id}"} variant="outline">
            View issue
          </.button>
        </div>
      </div>

      <div class="rounded-2xl border border-base bg-base p-6 shadow-base">
        <p class="whitespace-pre-wrap text-sm leading-6">{@report.body}</p>
      </div>

      <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-3">
        <h2 class="text-sm font-semibold">Reporter (optional)</h2>
        <div class="text-sm text-foreground-soft">
          <span class="font-medium text-foreground">
            {@report.reporter_name || "Anonymous"}
          </span>
          <%= if @report.reporter_email && @report.reporter_email != "" do %>
            <span class="mx-2">•</span>
            <span>{@report.reporter_email}</span>
          <% end %>
          <%= if @report.reporter_phone && @report.reporter_phone != "" do %>
            <span class="mx-2">•</span>
            <span>{@report.reporter_phone}</span>
          <% end %>
        </div>
      </div>

      <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
        <h2 class="text-sm font-semibold">Assignment</h2>

        <.alert color="primary">
          Currently assigned to: <span class="font-medium">{@report.issue.title}</span>
          <span class="mx-2">•</span>
          <span class="text-foreground-soft">{@report.issue.status}</span>
        </.alert>

        <div class="grid gap-6 lg:grid-cols-2">
          <div class="space-y-3">
            <h3 class="text-sm font-semibold">Move to another issue</h3>
            <p class="text-sm text-foreground-soft">
              Use this when a report was grouped into the wrong issue.
            </p>

            <%= if @issue_options == [] do %>
              <div class="text-sm text-foreground-soft">
                No other issues exist for this location yet.
              </div>
            <% else %>
              <.form
                for={%{}}
                as={:move}
                id="report-move-form"
                phx-submit="move_report"
                class="space-y-3"
              >
                <.select
                  name="move[issue_id]"
                  label="Issue"
                  placeholder="Select an issue"
                  searchable
                  options={@issue_options}
                />

                <.button type="submit" variant="solid" color="primary" phx-disable-with="Moving...">
                  Move report
                </.button>
              </.form>
            <% end %>
          </div>

          <div class="space-y-3">
            <div class="flex items-center justify-between gap-4">
              <h3 class="text-sm font-semibold">Create a new issue</h3>
              <.button
                type="button"
                size="sm"
                variant="ghost"
                phx-click="toggle_new_issue"
                aria-expanded={to_string(@new_issue_open?)}
              >
                {if @new_issue_open?, do: "Hide", else: "Show"}
              </.button>
            </div>

            <p class="text-sm text-foreground-soft">
              Use this when the report describes a separate problem that deserves its own thread.
            </p>

            <div :if={@new_issue_open?} class="rounded-xl border border-base bg-accent p-4">
              <.form
                for={%{}}
                as={:new_issue}
                id="report-new-issue-form"
                phx-submit="create_issue"
                class="space-y-3"
              >
                <.input
                  name="new_issue[title]"
                  label="Issue title"
                  value={@new_issue_title}
                  required
                />

                <.textarea
                  name="new_issue[description]"
                  label="Issue description"
                  rows={4}
                  value={@report.body}
                  required
                />

                <.button type="submit" variant="solid" color="primary" phx-disable-with="Creating...">
                  Create issue + move report
                </.button>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_new_issue", _params, socket) do
    {:noreply, assign(socket, :new_issue_open?, not socket.assigns.new_issue_open?)}
  end

  @impl true
  def handle_event("move_report", %{"move" => %{"issue_id" => issue_id}}, socket) do
    tenant = socket.assigns.tenant
    report = socket.assigns.report
    user = socket.assigns.current_user
    from_issue = report.issue

    case Ash.update(report, %{issue_id: issue_id}, action: :reassign_issue, tenant: tenant) do
      {:ok, _updated} ->
        _ = log_report_move(tenant, user, report.id, from_issue, issue_id)
        {:noreply, refresh(socket, "Report moved.")}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to move report: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("create_issue", %{"new_issue" => params}, socket) do
    tenant = socket.assigns.tenant
    report = socket.assigns.report
    user = socket.assigns.current_user
    from_issue = report.issue

    title = params |> Map.get("title") |> to_string() |> String.trim()
    description = params |> Map.get("description") |> to_string() |> String.trim()

    with true <- title != "" || {:error, "Title is required"},
         true <- description != "" || {:error, "Description is required"},
         {:ok, issue} <-
           Ash.create(
             Issue,
             %{
               location_id: report.location_id,
               title: title,
               description: description,
               normalized_description: report.normalized_body,
               status: :new
             },
             tenant: tenant
           ),
         {:ok, _report} <-
           Ash.update(report, %{issue_id: issue.id}, action: :reassign_issue, tenant: tenant) do
      _ = log_report_split(tenant, user, report.id, from_issue, issue)
      {:noreply, refresh(socket, "Created a new issue and moved the report.")}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to create issue: #{inspect(err)}")}
    end
  end

  defp refresh(socket, flash_msg) do
    tenant = socket.assigns.tenant
    report_id = socket.assigns.report.id

    with {:ok, report} <- get_report(tenant, report_id),
         {:ok, issues} <- list_issue_options(tenant, report.location_id, report.issue_id) do
      socket
      |> put_flash(:info, flash_msg)
      |> assign(:report, report)
      |> assign(:issue_options, build_issue_options(issues))
    else
      _ ->
        socket
    end
  end

  defp log_report_move(tenant, user, report_id, from_issue, to_issue_id) do
    with {:ok, to_issue} <- Ash.get(Issue, to_issue_id, tenant: tenant) do
      body =
        "Moved report #{report_id} from \"#{from_issue.title}\" to \"#{to_issue.title}\"."

      attrs = %{
        body: body,
        author_user_id: user.id,
        author_email: to_string(user.email)
      }

      _ = Ash.create(IssueComment, Map.put(attrs, :issue_id, from_issue.id), tenant: tenant)
      _ = Ash.create(IssueComment, Map.put(attrs, :issue_id, to_issue.id), tenant: tenant)
    end

    :ok
  end

  defp log_report_split(tenant, user, report_id, from_issue, new_issue) do
    attrs = %{
      author_user_id: user.id,
      author_email: to_string(user.email)
    }

    _ =
      Ash.create(
        IssueComment,
        Map.merge(attrs, %{
          issue_id: from_issue.id,
          body: "Moved report #{report_id} to a new issue: \"#{new_issue.title}\"."
        }),
        tenant: tenant
      )

    _ =
      Ash.create(
        IssueComment,
        Map.merge(attrs, %{
          issue_id: new_issue.id,
          body: "Created from report #{report_id} (moved from \"#{from_issue.title}\")."
        }),
        tenant: tenant
      )

    :ok
  end
end
