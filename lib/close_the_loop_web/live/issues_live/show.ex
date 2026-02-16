defmodule CloseTheLoopWeb.IssuesLive.Show do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.Text
  alias CloseTheLoop.Events
  alias CloseTheLoop.Events.ChangeMetadata
  alias CloseTheLoop.Accounts
  alias CloseTheLoopWeb.ActivityFeed
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    tenant = socket.assigns.current_tenant
    user = socket.assigns.current_user

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, issue} <- get_issue(tenant, id),
         {:ok, reports} <- list_reports(tenant, id),
         {:ok, comments} <- list_comments(tenant, id),
         {:ok, {events, users_by_id, issues_by_id}} <-
           load_activity(tenant, issue, reports, comments) do
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
         |> assign(:activity_issues_by_id, issues_by_id)
         |> assign(:category_labels, Categories.key_label_map(tenant))
         |> assign(:active_category_labels, Categories.active_key_label_map(tenant))
         |> assign(:add_update_modal_open?, false)
         |> assign(:add_update_form, add_update_form(tenant, issue, user))
         |> assign(:update_modal_open?, false)
         |> assign(:update_form, update_form(tenant, issue, user))
         |> assign(:new_report_modal_open?, false)
         |> assign(:new_report_form, new_report_form(tenant, issue, user))
         |> assign(:can_edit_issue?, can_edit_issue?(socket.assigns.current_role))
         |> assign(:editing_details?, false)
         |> assign(:details_form, details_form(tenant, issue, user))
         |> assign(:details_error, nil)}
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
        sort: [updated_at: :desc, inserted_at: :desc]
      ]
    )
  end

  defp list_comments(tenant, issue_id) do
    Feedback.list_issue_comments(
      tenant: tenant,
      query: [
        filter: [issue_id: issue_id],
        sort: [updated_at: :desc, inserted_at: :desc]
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

    meta_issue_ids =
      events
      |> Enum.flat_map(fn e ->
        meta = e.metadata || %{}
        [meta["from_issue_id"], meta["to_issue_id"]]
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    issues_by_id =
      if meta_issue_ids == [] do
        %{}
      else
        case Feedback.list_issues(tenant: tenant, query: [filter: [id: [in: meta_issue_ids]]]) do
          {:ok, issues} -> Map.new(issues, &{&1.id, &1})
          _ -> %{}
        end
      end

    user_ids =
      events
      |> Enum.map(& &1.user_id)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    users_by_id =
      if user_ids == [] do
        %{}
      else
        case Accounts.list_users(query: [filter: [id: [in: user_ids]]]) do
          {:ok, users} -> Map.new(users, &{&1.id, &1})
          _ -> %{}
        end
      end

    {:ok, {events, users_by_id, issues_by_id}}
  end

  defp load_activity(_tenant, _issue, _reports, _comments), do: {:ok, {[], %{}, %{}}}

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
        <div class="min-w-0">
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
            <span class="mx-2">•</span>
            <.badge variant="surface" color={status_badge_color(@issue.status)}>
              {status_label(@issue.status)}
            </.badge>
          </div>
        </div>

        <div
          id="issue-actions-card"
          class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4"
        >
          <div class="grid grid-cols-2 gap-2 sm:flex sm:flex-wrap sm:items-center">
            <.button
              id="issue-open-add-update"
              type="button"
              size="sm"
              variant="solid"
              color="primary"
              phx-click="open_add_update_modal"
              class="col-span-2 w-full sm:w-auto"
            >
              Add update
            </.button>

            <.button
              :if={@can_edit_issue? and not @editing_details?}
              id="issue-edit-details-toggle"
              type="button"
              size="sm"
              variant="outline"
              phx-click="issue_details_toggle"
              class="w-full sm:w-auto"
            >
              <.icon name="hero-pencil-square" class="size-4" /> Edit details
            </.button>

            <.button
              id="issue-open-send-sms"
              type="button"
              size="sm"
              variant="outline"
              phx-click="open_update_modal"
              class="w-full sm:w-auto"
            >
              Send SMS
            </.button>

            <.button
              id="issue-open-add-report"
              type="button"
              size="sm"
              variant="outline"
              phx-click="open_new_report_modal"
              class="w-full sm:w-auto"
            >
              <.icon name="hero-plus" class="size-4" /> Add report
            </.button>
          </div>
        </div>

        <.modal
          id="issue-add-update-modal"
          open={@add_update_modal_open?}
          on_close={JS.push("close_add_update_modal")}
          class="w-full max-w-lg"
        >
          <div class="p-6 space-y-4">
            <div>
              <h3 class="text-lg font-semibold">Add update</h3>
              <p class="mt-1 text-sm text-foreground-soft">
                Optionally update status and/or add an internal note.
              </p>
            </div>

            <.form
              for={@add_update_form}
              id="issue-add-update-form"
              phx-change="validate"
              phx-submit="submit_update"
              class="space-y-4"
            >
              <input
                type="hidden"
                name={@add_update_form[:status].name}
                id={@add_update_form[:status].id}
                value={@add_update_form.params["status"] || ""}
              />

              <div class="space-y-2">
                <div class="flex items-center justify-between gap-2">
                  <h4 class="text-sm font-semibold">Status</h4>
                  <span class="text-xs text-foreground-soft">Optional</span>
                </div>

                <.button_group>
                  <.button
                    :for={{label, value} <- status_options()}
                    type="button"
                    size="sm"
                    color="primary"
                    variant={
                      if(@add_update_form.params["status"] == to_string(value),
                        do: "solid",
                        else: "outline"
                      )
                    }
                    phx-click="pick_update_status"
                    phx-value-status={value}
                  >
                    {label}
                  </.button>
                </.button_group>
              </div>

              <div class="space-y-2">
                <div class="flex items-center justify-between gap-2">
                  <h4 class="text-sm font-semibold">Internal comment</h4>
                  <span class="text-xs text-foreground-soft">Optional</span>
                </div>

                <.textarea
                  id="issue-add-update-comment-body"
                  field={@add_update_form[:comment_body]}
                  rows={4}
                  placeholder="Called maintenance; plumber scheduled for Tuesday."
                />
                <p class="text-xs text-foreground-soft">Visible only to your team.</p>
              </div>

              <div class="flex items-center justify-end gap-2 pt-2">
                <.button type="button" variant="outline" phx-click="close_add_update_modal">
                  Cancel
                </.button>
                <.button type="submit" variant="solid" color="primary" phx-disable-with="Saving...">
                  Save update
                </.button>
              </div>
            </.form>
          </div>
        </.modal>

        <div id="issue-details-card" class="rounded-2xl border border-base bg-base p-6 shadow-base">
          <h2 class="text-sm font-semibold">Details</h2>

          <%= if @editing_details? do %>
            <.form
              for={@details_form}
              id="issue-edit-details-form"
              phx-change="validate"
              phx-submit="issue_details_save"
              class="mt-4 space-y-4"
            >
              <.input
                id="issue-edit-title"
                field={@details_form[:title]}
                type="text"
                label="Title"
                required
              />

              <div>
                <label for="issue-edit-description" class="text-xs font-medium text-foreground-soft">
                  Description
                </label>
                <.textarea
                  id="issue-edit-description"
                  field={@details_form[:description]}
                  rows={6}
                  required
                />
              </div>

              <%= if @details_error do %>
                <.alert color="danger" hide_close>{@details_error}</.alert>
              <% end %>

              <div class="flex items-center justify-end gap-2">
                <.button
                  id="issue-edit-details-cancel"
                  type="button"
                  variant="outline"
                  phx-click="issue_details_cancel"
                >
                  Cancel
                </.button>
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
          <div>
            <h2 class="text-sm font-semibold">SMS updates</h2>
            <p class="mt-1 text-sm text-foreground-soft">
              Queued updates for {@issue.reporter_count} reporter(s). Use "Send SMS" in Actions to send another.
            </p>
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
                phx-change="validate"
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
          <h2 class="text-sm font-semibold">Reports</h2>

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
                phx-change="validate"
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

          <div :if={@reports == []} class="py-10 text-center text-sm text-foreground-soft">
            No reports yet.
          </div>

          <div
            :if={@reports != []}
            class="rounded-2xl border border-base bg-base shadow-base overflow-hidden"
          >
            <.navlist class="divide-y divide-base space-y-0 rounded-none border-0 p-0 [&+[data-part=navlist]]:mt-0">
              <.navlink
                :for={r <- @reports}
                id={"issue-report-link-#{r.id}"}
                navigate={~p"/app/#{@current_org.id}/reports/#{r.id}"}
                class="ml-0 px-5 py-4 rounded-none hover:bg-accent/40 transition"
              >
                <div class="min-w-0 flex-1">
                  <div class="flex flex-wrap items-center gap-2 text-xs text-foreground-soft">
                    <time
                      id={"issue-report-time-#{r.id}"}
                      phx-hook="LocalTime"
                      data-iso={iso8601(r.inserted_at)}
                      class="font-medium"
                    >
                      {format_dt(r.inserted_at)}
                    </time>
                    <.badge variant="surface" color={report_source_badge_color(r.source)}>
                      {report_source_label(r.source)}
                    </.badge>
                  </div>

                  <div class="mt-1 text-sm leading-6 text-foreground line-clamp-2">
                    {report_preview(r.body)}
                  </div>
                </div>

                <.icon name="hero-chevron-right" class="ml-auto size-4 text-foreground-soft" />
              </.navlink>
            </.navlist>
          </div>
        </div>

        <ActivityFeed.activity_feed
          id="issue-activity"
          events={@activity_events}
          users_by_id={@activity_users_by_id}
          issues_by_id={@activity_issues_by_id}
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
  def handle_event("validate", %{"update" => params}, socket) when is_map(params) do
    # Keep the `update[confirm]` checkbox out of the Ash form params.
    params =
      params
      |> Map.take(["message"])
      |> Map.update("message", "", &(&1 |> to_string() |> String.trim()))

    form = AshPhoenix.Form.validate(socket.assigns.update_form, params)
    {:noreply, assign(socket, :update_form, form)}
  end

  def handle_event("validate", %{"issue_update" => params}, socket) when is_map(params) do
    form = AshPhoenix.Form.validate(socket.assigns.add_update_form, params)
    {:noreply, assign(socket, :add_update_form, form)}
  end

  def handle_event("validate", %{"new_report" => params}, socket) when is_map(params) do
    params = Map.update(params, "body", "", &(&1 |> to_string() |> String.trim()))
    form = AshPhoenix.Form.validate(socket.assigns.new_report_form, params)
    {:noreply, assign(socket, :new_report_form, form)}
  end

  def handle_event("validate", %{"issue" => params}, socket) when is_map(params) do
    params = %{
      "title" => params |> Map.get("title", "") |> to_string() |> String.trim(),
      "description" => params |> Map.get("description", "") |> to_string() |> String.trim()
    }

    form = AshPhoenix.Form.validate(socket.assigns.details_form, params)
    {:noreply, socket |> assign(:details_form, form) |> assign(:details_error, nil)}
  end

  def handle_event("open_add_update_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:add_update_modal_open?, true)
     |> assign(
       :add_update_form,
       add_update_form(socket.assigns.tenant, socket.assigns.issue, socket.assigns.current_user)
     )}
  end

  def handle_event("close_add_update_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:add_update_modal_open?, false)
     |> assign(
       :add_update_form,
       add_update_form(socket.assigns.tenant, socket.assigns.issue, socket.assigns.current_user)
     )}
  end

  def handle_event("pick_update_status", %{"status" => status_str}, socket) do
    status_str = status_str |> to_string() |> String.trim()

    current_params = socket.assigns.add_update_form.params || %{}
    params = Map.put(current_params, "status", status_str)

    form = AshPhoenix.Form.validate(socket.assigns.add_update_form, params)
    {:noreply, assign(socket, :add_update_form, form)}
  end

  def handle_event("submit_update", %{"issue_update" => params}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user

    case Feedback.add_issue_update(issue, params, tenant: tenant, actor: user) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Update saved.")
         |> assign(:add_update_modal_open?, false)
         |> assign(:add_update_form, add_update_form(tenant, issue, user))
         |> reload_page()}

      {:error, form} ->
        {:noreply, assign(socket, :add_update_form, form)}
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
     |> assign(
       :update_form,
       update_form(socket.assigns.tenant, socket.assigns.issue, socket.assigns.current_user)
     )}
  end

  def handle_event("open_new_report_modal", _params, socket) do
    {:noreply, assign(socket, :new_report_modal_open?, true)}
  end

  def handle_event("close_new_report_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:new_report_modal_open?, false)
     |> assign(
       :new_report_form,
       new_report_form(socket.assigns.tenant, socket.assigns.issue, socket.assigns.current_user)
     )}
  end

  @impl true
  def handle_event("send_update", %{"update" => update_params}, socket) do
    tenant = socket.assigns.tenant
    user = socket.assigns.current_user
    confirmed? = truthy?(update_params["confirm"])
    message = update_params["message"] |> to_string() |> String.trim()

    if not confirmed? do
      {:noreply, put_flash(socket, :error, "Please confirm before sending.")}
    else
      case AshPhoenix.Form.submit(socket.assigns.update_form, params: %{"message" => message}) do
        {:ok, upd} ->
          case CloseTheLoop.Workers.SendIssueUpdateSmsWorker.enqueue(upd, tenant) do
            {:ok, _job} ->
              {:noreply,
               socket
               |> put_flash(:info, "Update queued (SMS).")
               |> assign(:update_modal_open?, false)
               |> assign(:update_form, update_form(tenant, socket.assigns.issue, user))
               |> reload_page()}

            {:error, err} ->
              {:noreply, put_flash(socket, :error, inspect(err))}
          end

        {:error, form} ->
          {:noreply, assign(socket, :update_form, form)}
      end
    end
  end

  @impl true
  def handle_event("create_manual_report", %{"new_report" => %{"body" => body}}, socket) do
    tenant = socket.assigns.tenant
    user = socket.assigns.current_user

    body = body |> to_string() |> String.trim()

    case AshPhoenix.Form.submit(socket.assigns.new_report_form, params: %{"body" => body}) do
      {:ok, _report} ->
        {:noreply,
         socket
         |> put_flash(:info, "Report added.")
         |> assign(:new_report_modal_open?, false)
         |> assign(:new_report_form, new_report_form(tenant, socket.assigns.issue, user))
         |> reload_page()}

      {:error, form} ->
        {:noreply, assign(socket, :new_report_form, form)}
    end
  end

  @impl true
  def handle_event("issue_details_toggle", _params, socket) do
    if socket.assigns.can_edit_issue? do
      {:noreply,
       socket
       |> assign(:editing_details?, true)
       |> assign(
         :details_form,
         details_form(socket.assigns.tenant, socket.assigns.issue, socket.assigns.current_user)
       )
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
     |> assign(
       :details_form,
       details_form(socket.assigns.tenant, socket.assigns.issue, socket.assigns.current_user)
     )
     |> assign(:details_error, nil)}
  end

  @impl true
  def handle_event("issue_details_save", %{"issue" => params}, socket) do
    if socket.assigns.can_edit_issue? do
      tenant = socket.assigns.tenant
      user = socket.assigns.current_user

      changes =
        ChangeMetadata.diff(socket.assigns.issue, params,
          fields: [:title, :description],
          trim?: true,
          empty_to_nil?: false
        )

      context = ChangeMetadata.context_for_changes(changes)

      case AshPhoenix.Form.submit(socket.assigns.details_form, params: params, context: context) do
        {:ok, issue} ->
          {:noreply,
           socket
           |> put_flash(:info, "Issue updated.")
           |> assign(:issue, issue)
           |> assign(:editing_details?, false)
           |> assign(:details_form, details_form(tenant, issue, user))
           |> assign(:details_error, nil)
           |> reload_page()}

        {:error, form} ->
          {:noreply,
           socket
           |> assign(:details_form, form)
           |> assign(:details_error, nil)}
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
         {:ok, {events, users_by_id, issues_by_id}} <-
           load_activity(tenant, issue, reports, comments) do
      socket
      |> assign(:issue, issue)
      |> assign(:reports, reports)
      |> assign(:activity_events, events)
      |> assign(:activity_users_by_id, users_by_id)
      |> assign(:activity_issues_by_id, issues_by_id)
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

  defp status_badge_color(:new), do: "info"
  defp status_badge_color(:acknowledged), do: "warning"
  defp status_badge_color(:in_progress), do: "warning"
  defp status_badge_color(:fixed), do: "success"
  defp status_badge_color(_), do: "primary"

  defp status_label(status) when is_atom(status) do
    status
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp status_label(other), do: other |> to_string() |> String.capitalize()

  defp report_source_label(source) do
    case source |> to_string() do
      "sms" -> "SMS"
      "manual" -> "Manual"
      other -> other |> String.replace("_", " ") |> String.capitalize()
    end
  end

  defp report_source_badge_color(source) do
    case source |> to_string() do
      "sms" -> "info"
      "manual" -> "primary"
      _ -> "warning"
    end
  end

  defp report_preview(body) do
    body
    |> to_string()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  defp can_edit_issue?(:owner), do: true
  defp can_edit_issue?(_), do: false

  defp add_update_form(tenant, issue, user) do
    Feedback.form_to_add_issue_update(issue, tenant: tenant, actor: user)
  end

  defp update_form(tenant, issue, user) do
    AshPhoenix.Form.for_create(CloseTheLoop.Feedback.IssueUpdate, :create,
      as: "update",
      id: "update",
      tenant: tenant,
      actor: user,
      params: %{"message" => ""},
      prepare_source: fn changeset ->
        Ash.Changeset.change_attribute(changeset, :issue_id, issue.id)
      end
    )
    |> to_form()
  end

  defp new_report_form(tenant, issue, user) do
    AshPhoenix.Form.for_create(CloseTheLoop.Feedback.Report, :create,
      as: "new_report",
      id: "new_report",
      tenant: tenant,
      actor: user,
      params: %{"body" => ""},
      prepare_source: fn changeset ->
        changeset
        |> Ash.Changeset.change_attribute(:issue_id, issue.id)
        |> Ash.Changeset.change_attribute(:location_id, issue.location_id)
        |> Ash.Changeset.change_attribute(:source, :manual)
        |> Ash.Changeset.change_attribute(:consent, false)
      end,
      prepare_params: fn params, _phase ->
        body = params |> Map.get("body", "") |> to_string()
        Map.put(params, "normalized_body", Text.normalize_for_dedupe(body))
      end
    )
    |> to_form()
  end

  defp details_form(tenant, issue, user) do
    AshPhoenix.Form.for_update(issue, :edit_details,
      as: "issue",
      id: "issue",
      tenant: tenant,
      actor: user
    )
    |> to_form()
  end
end
