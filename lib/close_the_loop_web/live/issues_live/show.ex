defmodule CloseTheLoopWeb.IssuesLive.Show do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Feedback

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    tenant = socket.assigns.current_tenant
    user = socket.assigns.current_user

    with true <- is_binary(tenant) || {:error, :missing_tenant},
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, issue} <- get_issue(tenant, id),
         {:ok, reports} <- list_reports(tenant, id),
         {:ok, comments} <- list_comments(tenant, id) do
      if issue.duplicate_of_issue_id do
        {:ok,
         socket
         |> put_flash(:info, "This issue was merged into another issue.")
         |> push_navigate(to: ~p"/app/issues/#{issue.duplicate_of_issue_id}")}
      else
        {:ok,
         socket
         |> assign(:tenant, tenant)
         |> assign(:issue, issue)
         |> assign(:reports, reports)
         |> assign(:category_labels, Categories.key_label_map(tenant))
         |> assign(:active_category_labels, Categories.active_key_label_map(tenant))
         |> assign(:update_form, to_form(%{"message" => ""}, as: :update))
         |> assign(:comment_form, to_form(%{"body" => ""}, as: :comment))
         |> assign(:can_edit_issue?, can_edit_issue?(user))
         |> assign(:editing_details?, false)
         |> assign(:details_form, details_form(issue))
         |> assign(:details_error, nil)
         |> assign(:comments_empty?, comments == [])
         |> stream(:comments, comments)}
      end
    else
      _ ->
        {:ok, put_flash(socket, :error, "Issue not found") |> push_navigate(to: ~p"/app/issues")}
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user} current_scope={@current_scope}>
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

          <.button navigate={~p"/app/issues"} variant="ghost">Back</.button>
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
          <h2 class="text-sm font-semibold">Send update to reporters</h2>

          <.form for={@update_form} id="issue-update-form" phx-submit="send_update" class="space-y-3">
            <.textarea
              field={@update_form[:message]}
              rows={3}
              placeholder="New water heater ordered. ETA Tuesday."
              required
            />

            <.button type="submit" variant="solid" color="primary" phx-disable-with="Sending...">
              Send update (SMS)
            </.button>
          </.form>

          <%= if @issue.updates != [] do %>
            <.separator text="Updates" class="my-4" />
            <ul class="space-y-3">
              <%= for upd <- @issue.updates do %>
                <li class="text-sm">
                  <div class="text-foreground-soft">{upd.inserted_at}</div>
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
              <div class="text-xs text-foreground-soft">
                <span class="font-medium text-foreground">{c.author_email || "Team"}</span>
                <span class="mx-2">•</span>
                <span>{c.inserted_at}</span>
              </div>
              <div class="mt-2 whitespace-pre-wrap text-sm leading-6">{c.body}</div>
            </div>
          </div>
        </div>

        <div class="rounded-2xl border border-base bg-base p-6 shadow-base space-y-4">
          <h2 class="text-sm font-semibold">Reports</h2>
          <ul class="space-y-3">
            <%= for r <- @reports do %>
              <li class="text-sm">
                <div class="flex items-start justify-between gap-3">
                  <div class="text-foreground-soft">
                    {r.inserted_at}
                    <span class="mx-2">•</span>
                    <span>{r.source}</span>
                  </div>
                  <.link
                    navigate={~p"/app/reports/#{r.id}"}
                    class="text-xs font-medium underline underline-offset-2 text-foreground-soft hover:text-foreground transition"
                  >
                    Reassign
                  </.link>
                </div>
                <div class="whitespace-pre-wrap">{r.body}</div>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("set_status", %{"status" => status_str}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user

    with {:ok, status} <- parse_status(status_str),
         {:ok, issue} <-
           Feedback.set_issue_status(issue, %{status: status}, tenant: tenant, actor: user) do
      {:noreply, assign(socket, :issue, issue)}
    else
      :error ->
        {:noreply, put_flash(socket, :error, "Invalid status")}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to update status: #{inspect(err)}")}
    end
  end

  @impl true
  def handle_event("send_update", %{"update" => %{"message" => message}}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user
    message = String.trim(message || "")

    with true <- message != "" || {:error, "Message is required"},
         {:ok, upd} <-
           Feedback.create_issue_update(%{issue_id: issue.id, message: message},
             tenant: tenant,
             actor: user
           ),
         {:ok, _job} <- CloseTheLoop.Workers.SendIssueUpdateSmsWorker.enqueue(upd, tenant) do
      {:noreply,
       socket
       |> put_flash(:info, "Update queued (SMS).")
       |> assign(:update_form, to_form(%{"message" => ""}, as: :update))
       |> reload_issue()}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, inspect(err))}
    end
  end

  @impl true
  def handle_event("add_comment", %{"comment" => %{"body" => body}}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    user = socket.assigns.current_user
    body = String.trim(body || "")

    with true <- body != "" || {:error, "Comment can't be blank"},
         {:ok, comment} <-
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
       |> assign(:comments_empty?, false)
       |> stream_insert(:comments, comment)
       |> put_flash(:info, "Internal comment added.")}
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
         |> assign(:details_error, nil)}
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

  defp reload_issue(socket) do
    tenant = socket.assigns.tenant
    issue_id = socket.assigns.issue.id

    case get_issue(tenant, issue_id) do
      {:ok, issue} -> assign(socket, :issue, issue)
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

  defp can_edit_issue?(%{role: :owner}), do: true
  defp can_edit_issue?(_), do: false

  defp details_form(issue) do
    to_form(%{"title" => issue.title, "description" => issue.description}, as: :issue)
  end
end
