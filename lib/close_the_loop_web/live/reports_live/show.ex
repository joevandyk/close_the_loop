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
      |> assign(:move_modal_open?, false)
      |> assign(:move_modal_tab, "existing")
      |> assign(:new_issue_form, to_form(%{"title" => "", "description" => ""}, as: :new_issue))

    tenant = socket.assigns.current_tenant

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         {:ok, report} <- get_report(tenant, id),
         {:ok, issues} <- list_issue_options(tenant, report.issue_id) do
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
         put_flash(socket, :error, "Report not found")
         |> push_navigate(to: ~p"/app/#{socket.assigns.current_org.id}/reports")}
    end
  end

  defp get_report(tenant, id) do
    Feedback.get_report_by_id(id,
      tenant: tenant,
      load: [issue: [:title, :status], location: [:name, :full_path]]
    )
  end

  defp list_issue_options(tenant, current_issue_id) do
    case Feedback.list_non_duplicate_issues(
           tenant: tenant,
           query: [
             sort: [inserted_at: :desc],
             limit: 500
           ],
           load: [location: [:name, :full_path]]
         ) do
      {:ok, issues} ->
        {:ok, Enum.reject(issues, &(&1.id == current_issue_id))}

      other ->
        other
    end
  end

  defp build_issue_options(issues) do
    Enum.map(issues, fn issue ->
      location = issue.location && (issue.location.full_path || issue.location.name)

      label =
        if is_binary(location) and String.trim(location) != "" do
          "#{location} — #{issue.title} (#{issue.status})"
        else
          "#{issue.title} (#{issue.status})"
        end

      {label, issue.id}
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

  defp iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp iso8601(other) when is_binary(other), do: other
  defp iso8601(other), do: to_string(other)

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
              <time
                id={"report-show-time-#{@report.id}"}
                phx-hook="LocalTime"
                data-iso={iso8601(@report.inserted_at)}
              >
                {format_dt(@report.inserted_at)}
              </time>
            </div>
          </div>

          <div class="flex items-center gap-2">
            <.button navigate={~p"/app/#{@current_org.id}/reports"} variant="ghost">Back</.button>
            <.button
              navigate={~p"/app/#{@current_org.id}/issues/#{@report.issue_id}"}
              variant="outline"
            >
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

          <div class="flex items-start justify-between gap-4">
            <p class="text-sm text-foreground-soft max-w-prose">
              If this report was assigned to the wrong issue, you can move it to an existing issue (even at a different
              location) or create a new issue for it.
            </p>

            <.button
              id="report-open-move-modal"
              type="button"
              variant="solid"
              color="primary"
              phx-click={Fluxon.open_dialog("report-move-modal") |> JS.push("open_move_modal")}
            >
              Move to another issue
            </.button>
          </div>

          <.modal
            id="report-move-modal"
            open={@move_modal_open?}
            on_close={JS.push("close_move_modal")}
            class="w-full max-w-2xl"
          >
            <div class="p-6 space-y-4">
              <div>
                <h3 class="text-lg font-semibold">Move report</h3>
                <p class="mt-1 text-sm text-foreground-soft">
                  Reassign to an existing issue, or create a new issue and move it there.
                </p>
              </div>

              <.tabs id="report-move-tabs">
                <.tabs_list active_tab={@move_modal_tab} variant="segmented" size="sm">
                  <:tab name="existing" phx-click={JS.push("set_move_tab", value: %{tab: "existing"})}>
                    Existing issue
                  </:tab>
                  <:tab name="new" phx-click={JS.push("set_move_tab", value: %{tab: "new"})}>
                    New issue
                  </:tab>
                </.tabs_list>

                <.tabs_panel
                  name="existing"
                  active={@move_modal_tab == "existing"}
                  class="mt-4 space-y-3"
                >
                  <p class="text-sm text-foreground-soft">
                    Use this when the report belongs on another issue (including an issue at a different location).
                  </p>

                  <%= if @issue_options == [] do %>
                    <.alert color="warning" hide_close>
                      No other issues exist yet. Create a new issue instead.
                    </.alert>

                    <div class="flex justify-end">
                      <.button
                        type="button"
                        size="sm"
                        variant="outline"
                        phx-click="set_move_tab"
                        phx-value-tab="new"
                      >
                        Create a new issue
                      </.button>
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

                      <div class="flex items-center justify-end gap-2">
                        <.button
                          type="submit"
                          variant="solid"
                          color="primary"
                          phx-disable-with="Moving..."
                        >
                          Move report
                        </.button>
                      </div>
                    </.form>
                  <% end %>
                </.tabs_panel>

                <.tabs_panel name="new" active={@move_modal_tab == "new"} class="mt-4 space-y-3">
                  <p class="text-sm text-foreground-soft">
                    Use this when the report describes a separate problem that deserves its own thread.
                  </p>

                  <div class="rounded-xl border border-base bg-accent p-4">
                    <.form
                      for={@new_issue_form}
                      id="report-new-issue-form"
                      phx-submit="create_issue"
                      class="space-y-3"
                    >
                      <.input field={@new_issue_form[:title]} label="Issue title" required />

                      <.textarea
                        field={@new_issue_form[:description]}
                        label="Issue description"
                        rows={4}
                        required
                      />

                      <div class="flex items-center justify-end gap-2">
                        <.button
                          type="submit"
                          variant="solid"
                          color="primary"
                          phx-disable-with="Creating..."
                        >
                          Create issue + move report
                        </.button>
                      </div>
                    </.form>
                  </div>
                </.tabs_panel>
              </.tabs>

              <div class="flex justify-end pt-2">
                <.button
                  id="report-move-modal-cancel"
                  type="button"
                  variant="outline"
                  phx-click={Fluxon.close_dialog("report-move-modal") |> JS.push("close_move_modal")}
                >
                  Cancel
                </.button>
              </div>
            </div>
          </.modal>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("open_move_modal", _params, socket) do
    tab = if socket.assigns.issue_options == [], do: "new", else: "existing"
    {:noreply, socket |> assign(:move_modal_open?, true) |> assign(:move_modal_tab, tab)}
  end

  @impl true
  def handle_event("close_move_modal", _params, socket) do
    {:noreply, reset_move_modal(socket)}
  end

  @impl true
  def handle_event("set_move_tab", %{"tab" => tab}, socket) when tab in ["existing", "new"] do
    {:noreply, assign(socket, :move_modal_tab, tab)}
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
        {:noreply, socket |> refresh("Report moved.") |> reset_move_modal()}

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

      {:noreply,
       socket |> refresh("Created a new issue and moved the report.") |> reset_move_modal()}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to create issue: #{inspect(err)}")}
    end
  end

  defp reset_move_modal(socket) do
    report = socket.assigns.report

    socket
    |> assign(:move_modal_open?, false)
    |> assign(:move_modal_tab, "existing")
    |> assign(:move_form, to_form(%{"issue_id" => ""}, as: :move))
    |> assign(
      :new_issue_form,
      to_form(
        %{"title" => default_issue_title(report.body), "description" => report.body},
        as: :new_issue
      )
    )
  end

  defp refresh(socket, flash_msg) do
    tenant = socket.assigns.current_tenant
    report_id = socket.assigns.report.id

    with {:ok, report} <- get_report(tenant, report_id),
         {:ok, issues} <- list_issue_options(tenant, report.issue_id) do
      socket
      |> put_flash(:info, flash_msg)
      |> assign(:report, report)
      |> assign(:issue_options, build_issue_options(issues))
    else
      _ ->
        socket
    end
  end

  defp log_report_move(tenant, user, _report_id, from_issue, to_issue_id) do
    with {:ok, to_issue} <- Feedback.get_issue_by_id(to_issue_id, tenant: tenant) do
      body =
        "Moved a report from \"#{from_issue.title}\" to \"#{to_issue.title}\"."

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

  defp log_report_split(tenant, user, _report_id, from_issue, new_issue) do
    attrs = %{
      author_user_id: user.id,
      author_email: to_string(user.email)
    }

    _ =
      Feedback.create_issue_comment(
        Map.merge(attrs, %{
          issue_id: from_issue.id,
          body: "Moved a report to a new issue: \"#{new_issue.title}\"."
        }),
        tenant: tenant,
        actor: user
      )

    _ =
      Feedback.create_issue_comment(
        Map.merge(attrs, %{
          issue_id: new_issue.id,
          body: "Created from a moved report (from \"#{from_issue.title}\")."
        }),
        tenant: tenant,
        actor: user
      )

    :ok
  end
end
