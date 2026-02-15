defmodule CloseTheLoopWeb.IssuesLive.Show do
  use CloseTheLoopWeb, :live_view
  on_mount {CloseTheLoopWeb.LiveUserAuth, :live_org_required}

  import Ash.Expr

  alias CloseTheLoop.Feedback.{Issue, IssueUpdate, Report}
  alias CloseTheLoop.Feedback.Categories
  alias CloseTheLoop.Tenants.Organization

  require Ash.Query

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = socket.assigns.current_user

    with {:ok, %Organization{} = org} <- Ash.get(Organization, user.organization_id),
         tenant when is_binary(tenant) <- org.tenant_schema,
         :ok <- Categories.ensure_defaults(tenant),
         {:ok, issue} <- get_issue(tenant, id),
         {:ok, reports} <- list_reports(tenant, id) do
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
         |> assign(:message, "")}
      end
    else
      _ ->
        {:ok, put_flash(socket, :error, "Issue not found") |> push_navigate(to: ~p"/app/issues")}
    end
  end

  defp get_issue(tenant, id) do
    Ash.get(Issue, id,
      load: [:reporter_count, :updates, location: [:name, :full_path]],
      tenant: tenant
    )
  end

  defp list_reports(tenant, issue_id) do
    query =
      Report
      |> Ash.Query.filter(expr(issue_id == ^issue_id))
      |> Ash.Query.sort(inserted_at: :desc)

    Ash.read(query, tenant: tenant)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto space-y-6">
      <div class="flex items-start justify-between gap-4">
        <div>
          <h1 class="text-2xl font-semibold">{@issue.title}</h1>
          <div class="text-base-content/70 mt-1">
            <span>Location:</span>
            <span class="font-medium">{@issue.location.full_path || @issue.location.name}</span>
            <span class="mx-2">•</span>
            <span>{@issue.reporter_count} reporter(s)</span>
            <%= if @issue.category && @issue.category != "" do %>
              <span class="mx-2">•</span>
              <span class="badge badge-ghost">
                {Map.get(@category_labels, @issue.category, @issue.category)}
              </span>
            <% end %>
          </div>
        </div>

        <.link class="btn" navigate={~p"/app/issues"}>Back</.link>
      </div>

      <div class="card bg-base-100 border">
        <div class="card-body">
          <p class="whitespace-pre-wrap">{@issue.description}</p>
        </div>
      </div>

      <div class="card bg-base-100 border">
        <div class="card-body space-y-4">
          <h2 class="card-title">Status</h2>

          <div class="flex gap-2 flex-wrap">
            <%= for {label, value} <- status_options() do %>
              <button
                type="button"
                class={"btn btn-sm #{if @issue.status == value, do: "btn-primary", else: "btn-outline"}"}
                phx-click="set_status"
                phx-value-status={value}
              >
                {label}
              </button>
            <% end %>
          </div>
        </div>
      </div>

      <div class="card bg-base-100 border">
        <div class="card-body space-y-4">
          <h2 class="card-title">Send update to reporters</h2>

          <.form for={%{}} as={:update} phx-submit="send_update" class="space-y-3">
            <textarea
              name="message"
              class="textarea textarea-bordered w-full"
              rows="3"
              placeholder="New water heater ordered. ETA Tuesday."
              required
            ><%= @message %></textarea>

            <button type="submit" class="btn btn-primary">
              Send update (SMS)
            </button>
          </.form>

          <%= if @issue.updates != [] do %>
            <div class="divider">Updates</div>
            <ul class="space-y-2">
              <%= for upd <- @issue.updates do %>
                <li class="text-sm">
                  <span class="text-base-content/70">{upd.inserted_at}</span>
                  <div class="whitespace-pre-wrap">{upd.message}</div>
                </li>
              <% end %>
            </ul>
          <% end %>
        </div>
      </div>

      <div class="card bg-base-100 border">
        <div class="card-body space-y-4">
          <h2 class="card-title">Reports</h2>
          <ul class="space-y-2">
            <%= for r <- @reports do %>
              <li class="text-sm">
                <span class="text-base-content/70">{r.inserted_at}</span>
                <div class="whitespace-pre-wrap">{r.body}</div>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("set_status", %{"status" => status_str}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue

    status =
      status_str
      |> to_string()
      |> String.to_existing_atom()

    case Ash.update(issue, %{status: status}, action: :set_status, tenant: tenant) do
      {:ok, issue} ->
        {:noreply, assign(socket, :issue, issue)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, "Failed to update status: #{inspect(err)}")}
    end
  rescue
    ArgumentError ->
      {:noreply, put_flash(socket, :error, "Invalid status")}
  end

  @impl true
  def handle_event("send_update", %{"message" => message}, socket) do
    tenant = socket.assigns.tenant
    issue = socket.assigns.issue
    message = String.trim(message || "")

    with true <- message != "" || {:error, "Message is required"},
         {:ok, upd} <-
           Ash.create(IssueUpdate, %{issue_id: issue.id, message: message}, tenant: tenant),
         {:ok, _job} <- CloseTheLoop.Workers.SendIssueUpdateSmsWorker.enqueue(upd, tenant) do
      {:noreply,
       socket
       |> put_flash(:info, "Update queued (SMS).")
       |> assign(:message, "")
       |> reload_issue()}
    else
      {:error, msg} when is_binary(msg) ->
        {:noreply, put_flash(socket, :error, msg)}

      {:error, err} ->
        {:noreply, put_flash(socket, :error, inspect(err))}
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
end
