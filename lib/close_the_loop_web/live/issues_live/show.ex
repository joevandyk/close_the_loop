defmodule CloseTheLoopWeb.IssuesLive.Show do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.Text
  alias CloseTheLoop.Events
  alias CloseTheLoop.Accounts
  alias CloseTheLoopWeb.ActivityFeed

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    tenant = socket.assigns.current_tenant

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, issue} <- get_issue(tenant, id),
         {:ok, reports} <- list_reports(tenant, id),
         {:ok, comments} <- list_comments(tenant, id),
         {:ok, {events, users_by_id}} <- load_activity(tenant, issue, reports, comments) do
      if issue.duplicate_of_issue_id do
        {:ok,
         socket
         |> put_flash(:info, "This issue was merged into another issue.")
         |> push_navigate(
           to: ~p"/app/#{socket.assigns.current_org.id}/issues/#{issue.duplicate_of_issue_id}"
         )}
      else
        {:ok,
         socket
         |> assign(:tenant, tenant)
         |> assign(:issue, issue)
         |> assign(:reports, reports)
         |> assign(:activity_events, events)
         |> assign(:activity_users_by_id, users_by_id)
         |> assign(:category_labels, Categories.key_label_map(tenant))
         |> assign(:active_category_labels, Categories.active_key_label_map(tenant))
         |> assign(:update_modal_open?, false)
         |> assign(:update_form, to_form(%{"message" => ""}, as: :update))
         |> assign(:new_report_modal_open?, false)
         |> assign(:new_report_form, to_form(%{"body" => ""}, as: :new_report))
         |> assign(:comment_form, to_form(%{"body" => ""}, as: :comment))
         |> assign(:can_edit_issue?, can_edit_issue?(socket.assigns.current_role))
         |> assign(:editing_details?, false)
         |> assign(:details_form, details_form(issue))
         |> assign(:details_error, nil)
         |> assign(:comments_empty?, comments == [])
         |> stream(:comments, comments)}
      end
    else
      _ ->
        {:ok,
         put_flash(socket, :error, "Issue not found")
         |> push_navigate(to: ~p"/app/#{socket.assigns.current_org.id}/issues")}
    end
  end

  defp get_issue(tenant, id) do
    Feedback.get_issue_by_id(id,
      tenant: tenant,
      load: [:reporter_count, :updates, location: [:name, :full_path]]
    )
  end

  defp list_reports(tenant, issue_id) do
    Feedback.list_reports(
      tenant: tenant,
      query: [
        filter: [issue_id: issue_id],
        sort: [inserted_at: :desc]
      ]
    )
  end

  defp list_comments(tenant, issue_id) do
    Feedback.list_issue_comments(
      tenant: tenant,
      query: [
        filter: [issue_id: issue_id],
        sort: [inserted_at: :asc]
      ]
    )
  end

  defp load_activity(tenant, issue, reports, comments) when is_binary(tenant) do
    # We avoid JSON-path filtering by constraining to the record_ids we already have.
    record_ids =
      [issue.id] ++
        Enum.map(reports, & &1.id) ++
        Enum.map(comments, & &1.id) ++
        Enum.map(issue.updates || [], & &1.id)

    record_ids = Enum.uniq(record_ids)

    events =
      case Events.list_events(
             tenant: tenant,
             query: [
               filter: [record_id: [in: record_ids]],
               sort: [occurred_at: :desc],
               limit: 200
             ]
           ) do
        {:ok, events} -> events
        _ -> []
      end

    user_ids =
      events
      |> Enum.map(& &1.user_id)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    users_by_id =
      Enum.reduce(user_ids, %{}, fn user_id, acc ->
        case Accounts.get_user_by_id(user_id) do
          {:ok, user} -> Map.put(acc, user.id, user)
          _ -> acc
        end
      end)

    {:ok, {events, users_by_id}}
  end

  defp load_activity(_tenant, _issue, _reports, _comments), do: {:ok, {[], %{}}}

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
            <h1 class="text-2xl font-semibold">{@issue.title}</h1>
            <div class="text-foreground-soft mt-1 text-sm">
              <span>Location:</span>
              <span class="font-medium">{@issue.location.full_path || @issue.location.name}</span>
              <span class="mx-2">•</span>
              <span>{@issue.reporter_count} reporter(s)</span>
              <%= if @issue.category && @issue.category != "" do %>
                <span class="mx-2">•</span>
                <% key = @issue.category %>
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
              <% end %>
            </div>
          </div>

          <.button navigate={~p"/app/#{@current_org.id}/issues"} variant="ghost">Back</.button>
        </div>

        <div id="issue-details-card" class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-sm font-semibold">Details</h2>
              <p class="mt-1 text-sm text-foreground-soft">
                Title and description used for triage and reporter updates.
              </p>
            </div>

            <%= if @can_edit_issue? do %>
              <%= if @editing_details? do %>
                <.button
                  id="issue-edit-details-cancel"
                  type="button"
                  size="sm"
                  variant="outline"
                  phx-click="issue_details_cancel"
                >
                  Cancel
                </.button>
              <% else %>
                <.button
                  id="issue-edit-details-toggle"
                  type="button"
                  size="sm"
                  variant="outline"
                  phx-click="issue_details_toggle"
                >
                  <.icon name="hero-pencil-square" class="size-4" /> Edit
                </.button>
              <% end %>
            <% end %>
          </div>

          <%= if @editing_details? do %>
            <.form
              for={@details_form}
              id="issue-edit-details-form"
              phx-change="issue_details_change"
              phx-submit="issue_details_save"
              class="mt-4 space-y-4"
            >
              <.input
                id="issue-edit-title"
                name={@details_form[:title].name}
                type="text"
                label="Title"
                value={@details_form[:title].value}
                required
              />

              <div>
                <label for="issue-edit-description" class="text-xs font-medium text-foreground-soft">
                  Description
                </label>
                <.textarea
                  id="issue-edit-description"
                  name={@details_form[:description].name}
                  rows={6}
                  value={@details_form[:description].value}
                  required
                />
              </div>

              <%= if @details_error do %>
                <.alert color="danger" hide_close>{@details_error}</.alert>
              <% end %>

              <div class="flex items-center justify-end gap-2">
                <.button type="submit" variant="solid" color="primary" phx-disable-with="Saving...">
                  Save changes
                </.button>
              </div>
            </.form>
          <% else %>
            <p class="mt-4 whitespace-pre-wrap text-sm leading-6">{@issue.description}</p>
          <% end %>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
          <h2 class="text-sm font-semibold">Status</h2>

          <.button_group>
            <.button
              :for={{label, value} <- status_options()}
              type="button"
              size="sm"
              color="primary"
              variant={if @issue.status == value, do: "solid", else: "outline"}
              phx-click="set_status"
              phx-value-status={value}
            >
              {label}
            </.button>
          </.button_group>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-sm font-semibold">Send SMS</h2>
              <p class="mt-1 text-sm text-foreground-soft">
                Sends to {@issue.reporter_count} reporter(s) associated with this issue.
              </p>
            </div>

            <.button
              id="issue-open-send-sms"
              type="button"
              variant="solid"
              color="primary"
              phx-click="open_update_modal"
            >
              Send SMS
            </.button>
          </div>

          <.modal
            id="issue-send-sms-modal"
            open={@update_modal_open?}
            on_close={JS.push("close_update_modal")}
            class="w-full max-w-lg"
          >
            <div class="p-6 space-y-4">
              <div>
                <h3 class="text-lg font-semibold">Send SMS update</h3>
                <p class="mt-1 text-sm text-foreground-soft">
                  This will notify {@issue.reporter_count} reporter(s).
                </p>
              </div>

              <.form
                for={@update_form}
                id="issue-send-sms-form"
                phx-submit="send_update"
                class="space-y-4"
              >
                <.textarea
                  field={@update_form[:message]}
                  rows={4}
                  placeholder="Quick update…"
                  required
                />

                <.checkbox
                  name="update[confirm]"
                  value="true"
                  checked={false}
                  label={"I understand this will send an SMS to #{@issue.reporter_count} reporter(s)."}
                />

                <div class="flex items-center justify-end gap-2 pt-2">
                  <.button type="button" variant="outline" phx-click="close_update_modal">
                    Cancel
                  </.button>
                  <.button
                    type="submit"
                    variant="solid"
                    color="primary"
                    phx-disable-with="Queueing..."
                  >
                    Send SMS
                  </.button>
                </div>
              </.form>
            </div>
          </.modal>

          <%= if @issue.updates != [] do %>
            <.separator text="Updates" class="my-4" />
            <ul class="space-y-3">
              <%= for upd <- @issue.updates do %>
                <li class="text-sm">
                  <time
                    id={"issue-update-time-#{upd.id}"}
                    phx-hook="LocalTime"
                    data-iso={iso8601(upd.inserted_at)}
                    class="text-foreground-soft"
                  >
                    {format_dt(upd.inserted_at)}
                  </time>
                  <div class="whitespace-pre-wrap">{upd.message}</div>
                </li>
              <% end %>
            </ul>
          <% end %>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-sm font-semibold">Internal comments</h2>
              <p class="mt-1 text-sm text-foreground-soft">
                Visible only to your team. Great for triage, follow-ups, and resolution notes.
              </p>
            </div>
          </div>

          <.form
            for={@comment_form}
            id="issue-internal-comment-form"
            phx-submit="add_comment"
            class="space-y-3"
          >
            <.textarea
              field={@comment_form[:body]}
              rows={3}
              placeholder="Called maintenance; plumber scheduled for Tuesday."
              required
            />

            <.button type="submit" variant="solid" color="primary" phx-disable-with="Adding...">
              Add internal comment
            </.button>
          </.form>

          <%= if @comments_empty? do %>
            <div class="text-sm text-foreground-soft">
              No internal comments yet.
            </div>
          <% end %>

          <div id="issue-comments" phx-update="stream" class="space-y-3">
            <div
              :for={{dom_id, c} <- @streams.comments}
              id={dom_id}
              class="rounded-xl border border-base bg-accent p-4"
            >
              <div class="grid grid-cols-[1fr_auto] items-center gap-x-3 gap-y-1">
                <div class="min-w-0 flex items-center gap-2 text-xs text-foreground-soft">
                  <span class="font-medium text-foreground truncate">{c.author_email || "Team"}</span>
                </div>

                <time
                  id={"issue-comment-time-#{c.id}"}
                  phx-hook="LocalTime"
                  data-iso={iso8601(c.inserted_at)}
                  class="shrink-0 text-xs font-medium text-foreground-soft"
                >
                  {format_dt(c.inserted_at)}
                </time>
              </div>
              <div class="mt-2 whitespace-pre-wrap text-sm leading-6">
                {ActivityFeed.scrub_raw_ids(c.body)}
              </div>
            </div>
          </div>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-sm font-semibold">Reports</h2>
              <p class="mt-1 text-sm text-foreground-soft">
                Add internal reports to capture more detail.
              </p>
            </div>

            <.button
              id="issue-open-add-report"
              type="button"
              size="sm"
              variant="outline"
              phx-click="open_new_report_modal"
            >
              <.icon name="hero-plus" class="size-4" /> Add report
            </.button>
          </div>

          <.modal
            id="issue-add-report-modal"
            open={@new_report_modal_open?}
            on_close={JS.push("close_new_report_modal")}
            class="w-full max-w-lg"
          >
            <div class="p-6 space-y-4">
              <div>
                <h3 class="text-lg font-semibold">Add report to this issue</h3>
                <p class="mt-1 text-sm text-foreground-soft">
                  Creates a manual report and attaches it to this issue.
                </p>
              </div>

              <.form
                for={@new_report_form}
                id="issue-add-report-form"
                phx-submit="create_manual_report"
              >
                <.textarea
                  id="issue-add-report-body"
                  field={@new_report_form[:body]}
                  rows={6}
                  placeholder="What did you observe?"
                  required
                />

                <div class="mt-4 flex items-center justify-end gap-2">
                  <.button type="button" variant="outline" phx-click="close_new_report_modal">
                    Cancel
                  </.button>
                  <.button type="submit" variant="solid" color="primary" phx-disable-with="Adding...">
                    Add report
                  </.button>
                </div>
              </.form>
            </div>
          </.modal>

          <ul class="space-y-3">
            <%= for r <- @reports do %>
              <li class="rounded-xl border border-base bg-accent p-4">
                <div class="flex items-start justify-between gap-3">
                  <.link
                    id={"issue-report-link-#{r.id}"}
                    navigate={~p"/app/#{@current_org.id}/reports/#{r.id}"}
                    class="flex-1 -m-2 rounded-lg p-2 hover:bg-base/60 transition"
                  >
                    <div class="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-foreground-soft">
                      <time
                        id={"issue-report-time-#{r.id}"}
                        phx-hook="LocalTime"
                        data-iso={iso8601(r.inserted_at)}
                      >
                        {format_dt(r.inserted_at)}
                      </time>
                      <span class="opacity-60">•</span>
                      <span>{r.source}</span>
                    </div>

                    <div class="mt-2 whitespace-pre-wrap text-sm leading-6 text-foreground">
                      {r.body}
                    </div>
                  </.link>

                  <.link
                    navigate={~p"/app/#{@current_org.id}/reports/#{r.id}"}
                    class="shrink-0 text-xs font-medium underline underline-offset-2 text-foreground-soft hover:text-foreground transition"
                  >
                    Reassign
                  </.link>
                </div>
              </li>
            <% end %>
          </ul>
        </div>

        <ActivityFeed.activity_feed
          id="issue-activity"
          events={@activity_events}
          users_by_id={@activity_users_by_id}
          current_user={@current_user}
          org={@current_org}
        />
      </div>
    </Layouts.app>
    """
  end

  defp iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp iso8601(%Date{} = d), do: Date.to_iso8601(d)
  defp iso8601(dt) when is_binary(dt), do: dt
  defp iso8601(dt), do: to_string(dt)

  defp format_dt(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %-I:%M %p")
  defp format_dt(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%b %-d, %Y %-I:%M %p")
  defp format_dt(dt) when is_binary(dt), do: dt
  defp format_dt(dt), do: to_string(dt)

  defp truthy?(val) when val in [true, "true", "on", "1"], do: true
  defp truthy?(_), do: false

  @impl true
  def handle_event("set_status", %{"status" => status_str}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user

    with {:ok, status} <- parse_status(status_str),
         {:ok, issue} <-
           Feedback.set_issue_status(issue, %{status: status},
             tenant: tenant,
             actor: user,
             context: %{
               ash_events_metadata: %{
                 "changes" => %{
                   "status" => %{
                     "from" => to_string(issue.status),
                     "to" => to_string(status)
                   }
                 }
               }
             }
           ) do
      {:noreply, socket |> assign(:issue, issue) |> reload_page()}
    else
      :error ->
        {:noreply, put_flash(socket, :error, "Invalid status")}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to update status: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("open_update_modal", _params, socket) do
    {:noreply, assign(socket, :update_modal_open?, true)}
  end

  def handle_event("close_update_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:update_modal_open?, false)
     |> assign(:update_form, to_form(%{"message" => ""}, as: :update))}
  end

  def handle_event("open_new_report_modal", _params, socket) do
    {:noreply, assign(socket, :new_report_modal_open?, true)}
  end

  def handle_event("close_new_report_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:new_report_modal_open?, false)
     |> assign(:new_report_form, to_form(%{"body" => ""}, as: :new_report))}
  end

  @impl true
  def handle_event("send_update", %{"update" => update_params}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user
    message = update_params["message"] |> to_string() |> String.trim()
    confirmed? = truthy?(update_params["confirm"])

    with true <- message != "" || {:error, "Message is required"},
         true <- confirmed? || {:error, "Please confirm before sending."},
         {:ok, upd} <-
           Feedback.create_issue_update(%{issue_id: issue.id, message: message},
             tenant: tenant,
             actor: user
           ),
         {:ok, _job} <- CloseTheLoop.Workers.SendIssueUpdateSmsWorker.enqueue(upd, tenant) do
      {:noreply,
       socket
       |> put_flash(:info, "Update queued (SMS).")
       |> assign(:update_modal_open?, false)
       |> assign(:update_form, to_form(%{"message" => ""}, as: :update))
       |> reload_page()}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, inspect(err))}
    end
  end

  @impl true
  def handle_event("create_manual_report", %{"new_report" => %{"body" => body}}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user

    body = body |> to_string() |> String.trim()

    with true <- body != "" || {:error, "Report body is required"},
         normalized_body <- Text.normalize_for_dedupe(body),
         {:ok, _report} <-
           Feedback.create_report(
             %{
               location_id: issue.location_id,
               issue_id: issue.id,
               body: body,
               normalized_body: normalized_body,
               source: :manual,
               reporter_name: nil,
               reporter_email: nil,
               reporter_phone: nil,
               consent: false
             },
             tenant: tenant,
             actor: user
           ) do
      {:noreply,
       socket
       |> put_flash(:info, "Report added.")
       |> assign(:new_report_modal_open?, false)
       |> assign(:new_report_form, to_form(%{"body" => ""}, as: :new_report))
       |> reload_page()}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, Exception.message(err))}
    end
  end

  @impl true
  def handle_event("add_comment", %{"comment" => %{"body" => body}}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user
    body = String.trim(body || "")

    with true <- body != "" || {:error, "Comment can't be blank"},
         {:ok, _comment} <-
           Feedback.create_issue_comment(
             %{
               issue_id: issue.id,
               body: body,
               author_user_id: user.id,
               author_email: to_string(user.email)
             },
             tenant: tenant,
             actor: user
           ) do
      {:noreply,
       socket
       |> assign(:comment_form, to_form(%{"body" => ""}, as: :comment))
       |> put_flash(:info, "Internal comment added.")
       |> reload_page()}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to add comment: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("issue_details_toggle", _params, socket) do
    if socket.assigns.can_edit_issue? do
      {:noreply,
       socket
       |> assign(:editing_details?, true)
       |> assign(:details_form, details_form(socket.assigns.issue))
       |> assign(:details_error, nil)}
    else
      {:noreply, put_flash(socket, :error, "Only admins can edit issue details.")}
    end
  end

  @impl true
  def handle_event("issue_details_cancel", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing_details?, false)
     |> assign(:details_form, details_form(socket.assigns.issue))
     |> assign(:details_error, nil)}
  end

  @impl true
  def handle_event("issue_details_change", %{"issue" => params}, socket) do
    if socket.assigns.can_edit_issue? do
      {:noreply,
       socket
       |> assign(:details_form, to_form(params, as: :issue))
       |> assign(:details_error, nil)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("issue_details_save", %{"issue" => params}, socket) do
    if socket.assigns.can_edit_issue? do
      tenant = socket.assigns.tenant
      issue = socket.assigns.issue
      user = socket.assigns.current_user

      title = params |> Map.get("title", "") |> to_string() |> String.trim()
      description = params |> Map.get("description", "") |> to_string() |> String.trim()

      with true <- title != "" || {:error, "Title is required"},
           true <- description != "" || {:error, "Description is required"},
           {:ok, issue} <-
             Feedback.edit_issue_details(issue, %{title: title, description: description},
               tenant: tenant,
               actor: user
             ) do
        {:noreply,
         socket
         |> put_flash(:info, "Issue updated.")
         |> assign(:issue, issue)
         |> assign(:editing_details?, false)
         |> assign(:details_form, details_form(issue))
         |> assign(:details_error, nil)
         |> reload_page()}
      else
        {:error, msg} when is_binary(msg) ->
          {:noreply, assign(socket, :details_error, msg)}

        {:error, err} ->
          {:noreply, assign(socket, :details_error, Exception.message(err))}

        other ->
          {:noreply, assign(socket, :details_error, "Failed to save: #{inspect(other)}")}
      end
    else
      {:noreply, put_flash(socket, :error, "Only admins can edit issue details.")}
    end
  end

  defp reload_page(socket) do
    tenant = socket.assigns.tenant
    issue_id = socket.assigns.issue.id

    with {:ok, issue} <- get_issue(tenant, issue_id),
         {:ok, reports} <- list_reports(tenant, issue_id),
         {:ok, comments} <- list_comments(tenant, issue_id),
         {:ok, {events, users_by_id}} <- load_activity(tenant, issue, reports, comments) do
      socket
      |> assign(:issue, issue)
      |> assign(:reports, reports)
      |> assign(:comments_empty?, comments == [])
      |> assign(:activity_events, events)
      |> assign(:activity_users_by_id, users_by_id)
      |> stream(:comments, comments, reset: true)
    else
      _ -> socket
    end
  end

  defp status_options do
    [
      {"New", :new},
      {"Acknowledged", :acknowledged},
      {"In progress", :in_progress},
      {"Fixed", :fixed}
    ]
  end

  defp parse_status(val) do
    case val |> to_string() |> String.trim() do
      "new" -> {:ok, :new}
      "acknowledged" -> {:ok, :acknowledged}
      "in_progress" -> {:ok, :in_progress}
      "fixed" -> {:ok, :fixed}
      _ -> :error
    end
  end

  defp can_edit_issue?(:owner), do: true
  defp can_edit_issue?(_), do: false

  defp details_form(issue) do
    to_form(%{"title" => issue.title, "description" => issue.description}, as: :issue)
  end
end
