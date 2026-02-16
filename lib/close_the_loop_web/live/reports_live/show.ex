defmodule CloseTheLoopWeb.ReportsLive.Show do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(:report, nil)
      |> assign(:issue_options, [])
      |> assign(:move_form, to_form(%{"issue_id" => ""}, as: :move))
      |> assign(:new_issue_open?, false)
      |> assign(:new_issue_form, to_form(%{"title" => "", "description" => ""}, as: :new_issue))

    tenant = socket.assigns.current_tenant

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, report} <- get_report(tenant, id),
         {:ok, issues} <- list_issue_options(tenant, report.location_id, report.issue_id) do
      {:ok,
       socket
       |> assign(:report, report)
       |> assign(:issue_options, build_issue_options(issues))
       |> assign(
         :new_issue_form,
         to_form(
           %{"title" => default_issue_title(report.body), "description" => report.body},
           as: :new_issue
         )
       )}
    else
      _ ->
        {:ok,
         put_flash(socket, :error, "Report not found") |> push_navigate(to: ~p"/app/reports")}
    end
  end

  defp get_report(tenant, id) do
    Feedback.get_report_by_id(id,
      tenant: tenant,
      load: [issue: [:title, :status], location: [:name, :full_path]]
    )
  end

  defp list_issue_options(tenant, location_id, current_issue_id) do
    case Feedback.list_non_duplicate_issues(
           tenant: tenant,
           query: [
             filter: [location_id: location_id],
             sort: [inserted_at: :desc],
             limit: 101
           ]
         ) do
      {:ok, issues} ->
        {:ok, Enum.reject(issues, &(&1.id == current_issue_id))}

      other ->
        other
    end
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
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
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
                  for={@move_form}
                  id="report-move-form"
                  phx-submit="move_report"
                  class="space-y-3"
                >
                  <.select
                    field={@move_form[:issue_id]}
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
                  for={@new_issue_form}
                  id="report-new-issue-form"
                  phx-submit="create_issue"
                  class="space-y-3"
                >
                  <.input
                    field={@new_issue_form[:title]}
                    label="Issue title"
                    required
                  />

                  <.textarea
                    field={@new_issue_form[:description]}
                    label="Issue description"
                    rows={4}
                    required
                  />

                  <.button
                    type="submit"
                    variant="solid"
                    color="primary"
                    phx-disable-with="Creating..."
                  >
                    Create issue + move report
                  </.button>
                </.form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("toggle_new_issue", _params, socket) do
    {:noreply, assign(socket, :new_issue_open?, not socket.assigns.new_issue_open?)}
  end

  @impl true
  def handle_event("move_report", %{"move" => %{"issue_id" => issue_id}}, socket) do
    tenant = socket.assigns.current_tenant
    report = socket.assigns.report
    user = socket.assigns.current_user
    from_issue = report.issue

    case Feedback.reassign_report_issue(report, %{issue_id: issue_id},
           tenant: tenant,
           actor: user
         ) do
      {:ok, _updated} ->
        _ = log_report_move(tenant, user, report.id, from_issue, issue_id)
        {:noreply, refresh(socket, "Report moved.")}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to move report: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("create_issue", %{"new_issue" => params}, socket) do
    tenant = socket.assigns.current_tenant
    report = socket.assigns.report
    user = socket.assigns.current_user
    from_issue = report.issue

    title = params |> Map.get("title") |> to_string() |> String.trim()
    description = params |> Map.get("description") |> to_string() |> String.trim()

    with true <- title != "" || {:error, "Title is required"},
         true <- description != "" || {:error, "Description is required"},
         {:ok, issue} <-
           Feedback.create_issue(
             %{
               location_id: report.location_id,
               title: title,
               description: description,
               normalized_description: report.normalized_body,
               status: :new
             },
             tenant: tenant,
             actor: user
           ),
         {:ok, _report} <-
           Feedback.reassign_report_issue(report, %{issue_id: issue.id},
             tenant: tenant,
             actor: user
           ) do
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
    tenant = socket.assigns.current_tenant
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
    with {:ok, to_issue} <- Feedback.get_issue_by_id(to_issue_id, tenant: tenant) do
      body =
        "Moved report #{report_id} from \"#{from_issue.title}\" to \"#{to_issue.title}\"."

      attrs = %{
        body: body,
        author_user_id: user.id,
        author_email: to_string(user.email)
      }

      _ =
        Feedback.create_issue_comment(Map.put(attrs, :issue_id, from_issue.id),
          tenant: tenant,
          actor: user
        )

      _ =
        Feedback.create_issue_comment(Map.put(attrs, :issue_id, to_issue.id),
          tenant: tenant,
          actor: user
        )
    end

    :ok
  end

  defp log_report_split(tenant, user, report_id, from_issue, new_issue) do
    attrs = %{
      author_user_id: user.id,
      author_email: to_string(user.email)
    }

    _ =
      Feedback.create_issue_comment(
        Map.merge(attrs, %{
          issue_id: from_issue.id,
          body: "Moved report #{report_id} to a new issue: \"#{new_issue.title}\"."
        }),
        tenant: tenant,
        actor: user
      )

    _ =
      Feedback.create_issue_comment(
        Map.merge(attrs, %{
          issue_id: new_issue.id,
          body: "Created from report #{report_id} (moved from \"#{from_issue.title}\")."
        }),
        tenant: tenant,
        actor: user
      )

    :ok
  end
end
