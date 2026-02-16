defmodule CloseTheLoopWeb.ActivityFeed do
  @moduledoc """
  Reusable activity feed rendering for AshEvents-backed timelines.

  The calling LiveView is responsible for loading events + user lookup maps.
  """

  use CloseTheLoopWeb, :html

  attr :id, :string, default: nil
  attr :class, :any, default: nil

  attr :events, :list, default: []
  attr :users_by_id, :map, default: %{}
  attr :issues_by_id, :map, default: %{}
  attr :current_user, :any, default: nil
  attr :org, :any, default: nil

  attr :title, :string, default: "Timeline"
  attr :description, :string, default: "Status changes, internal comments, and SMS updates."

  def activity_feed(assigns) do
    id_prefix = assigns.id || "activity"

    assigns =
      assigns
      |> assign(:id_prefix, id_prefix)
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:id, fn -> nil end)

    ~H"""
    <div id={@id} class={["rounded-2xl border border-base bg-base p-6 shadow-base space-y-4", @class]}>
      <div>
        <h2 class="text-sm font-semibold">{@title}</h2>
        <p :if={@description} class="mt-1 text-sm text-foreground-soft">
          {@description}
        </p>
      </div>

      <div :if={@events == []} class="text-sm text-foreground-soft">
        No activity yet.
      </div>

      <ul :if={@events != []} class="space-y-3">
        <li
          :for={e <- @events}
          id={"#{@id_prefix}-event-#{e.id}"}
          class="rounded-xl border border-base bg-accent p-4"
        >
          <div class="space-y-2">
            <%= if path = time_link_path(@org, e) do %>
              <.link
                navigate={path}
                class="block -m-2 rounded-lg p-2 hover:bg-base/60 transition"
                aria-label={"View #{event_title(e)}"}
              >
                <div class="grid grid-cols-[1fr_auto] items-center gap-x-3 gap-y-1">
                  <div class="min-w-0 flex items-center gap-2 text-xs text-foreground-soft">
                    <span class="font-medium text-foreground">
                      {actor_label(@current_user, @users_by_id, e)}
                    </span>
                    <span class="opacity-60">•</span>
                    <span class="min-w-0 font-medium line-clamp-2">{event_title(e)}</span>
                  </div>

                  <time
                    id={"activity-time-#{e.id}"}
                    phx-hook="LocalTime"
                    data-iso={iso8601(e.occurred_at)}
                    class="shrink-0 text-xs font-medium text-foreground-soft"
                  >
                    {format_dt(e.occurred_at)}
                  </time>
                </div>
              </.link>
            <% else %>
              <div class="grid grid-cols-[1fr_auto] items-center gap-x-3 gap-y-1">
                <div class="min-w-0 flex items-center gap-2 text-xs text-foreground-soft">
                  <span class="font-medium text-foreground">
                    {actor_label(@current_user, @users_by_id, e)}
                  </span>
                  <span class="opacity-60">•</span>
                  <span class="min-w-0 font-medium line-clamp-2">{event_title(e)}</span>
                </div>

                <time
                  id={"activity-time-#{e.id}"}
                  phx-hook="LocalTime"
                  data-iso={iso8601(e.occurred_at)}
                  class="shrink-0 text-xs font-medium text-foreground-soft"
                >
                  {format_dt(e.occurred_at)}
                </time>
              </div>
            <% end %>

            <% summary = event_summary(@org, @issues_by_id, e) %>
            <%= if summary do %>
              <%= case summary do %>
                <% {:report_move, move_summary} -> %>
                  <div class="text-sm leading-6 text-foreground">
                    <.report_move_summary summary={move_summary} />
                  </div>
                <% {:field_changes, changes} -> %>
                  <div class="text-sm leading-6 text-foreground">
                    <.field_changes changes={changes} />
                  </div>
                <% summary when is_binary(summary) -> %>
                  <div class="whitespace-pre-wrap text-sm leading-6 text-foreground">{summary}</div>
              <% end %>
            <% end %>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  attr :summary, :map, required: true

  defp report_move_summary(assigns) do
    ~H"""
    <span>Moved a report from </span>

    <%= if @summary.org && @summary.from_issue do %>
      <.link
        navigate={~p"/app/#{@summary.org.id}/issues/#{@summary.from_issue_id}"}
        class="font-medium underline hover:no-underline"
      >
        {@summary.from_issue.title}
      </.link>
    <% else %>
      <span class="font-medium">{issue_title(@summary.from_issue, @summary.from_issue_id)}</span>
    <% end %>

    <span> to </span>

    <%= if @summary.org && @summary.to_issue do %>
      <.link
        navigate={~p"/app/#{@summary.org.id}/issues/#{@summary.to_issue_id}"}
        class="font-medium underline hover:no-underline"
      >
        {@summary.to_issue.title}
      </.link>
    <% else %>
      <span class="font-medium">{issue_title(@summary.to_issue, @summary.to_issue_id)}</span>
    <% end %>

    <span>.</span>
    """
  end

  defp actor_label(current_user, users_by_id, event) do
    cond do
      is_nil(event.user_id) ->
        "System"

      current_user && event.user_id == current_user.id ->
        "You"

      user = Map.get(users_by_id || %{}, event.user_id) ->
        to_string(user.email)

      true ->
        "Team"
    end
  end

  defp event_title(event) do
    resource = event.resource |> to_string() |> String.split(".") |> List.last()
    type = event.action_type |> to_string()

    case {resource, type} do
      {"IssueComment", "create"} -> "Internal comment added"
      {"IssueUpdate", "create"} -> "SMS update queued"
      {"Issue", "update"} -> issue_update_title(event)
      {"Report", "update"} -> report_update_title(event)
      {res, "create"} -> "Created #{res}"
      {res, "update"} -> "Updated #{res}"
      {res, "destroy"} -> "Deleted #{res}"
      {res, other} -> "#{String.capitalize(other)} #{res}"
    end
  end

  defp issue_update_title(event) do
    changes = changes_from_metadata(event)

    cond do
      not is_nil(issue_status_change(event)) ->
        "Status changed"

      Map.has_key?(changes, "title") or Map.has_key?(changes, "description") ->
        "Details updated"

      true ->
        "Issue updated"
    end
  end

  defp report_update_title(event) do
    meta = event.metadata || %{}
    changes = changes_from_metadata(event)

    move? =
      (is_binary(meta["from_issue_id"]) and is_binary(meta["to_issue_id"])) or
        Map.has_key?(changes, "issue_id") or
        Map.has_key?(changes, "location_id")

    if move? do
      "Report reassigned"
    else
      "Report updated"
    end
  end

  defp event_summary(org, issues_by_id, event) do
    resource = event.resource |> to_string() |> String.split(".") |> List.last()
    type = event.action_type |> to_string()
    data = event.data || %{}

    case {resource, type} do
      {"IssueComment", "create"} ->
        data["body"]

      {"IssueUpdate", "create"} ->
        data["message"]

      {"Issue", "update"} ->
        issue_update_summary(event)

      {"Report", "update"} ->
        report_update_summary(org, issues_by_id, event)

      _ ->
        nil
    end
  end

  defp issue_update_summary(event) do
    changes = changes_from_metadata(event)

    case issue_status_change(event) do
      {from, to} ->
        "Status: #{issue_status_label(from)} -> #{issue_status_label(to)}"

      nil ->
        cond do
          Map.has_key?(changes, "title") or Map.has_key?(changes, "description") ->
            {:field_changes, build_field_changes(changes, ["title", "description"])}

          true ->
            nil
        end
    end
  end

  defp issue_status_change(event) do
    changes = changes_from_metadata(event)

    case Map.get(changes, "status") do
      %{"from" => from, "to" => to} -> {from, to}
      _ -> nil
    end
  end

  defp issue_status_label(status) do
    case status |> to_string() do
      "new" -> "New"
      "acknowledged" -> "Acknowledged"
      "in_progress" -> "In progress"
      "fixed" -> "Fixed"
      other -> other |> String.replace("_", " ") |> String.capitalize()
    end
  end

  defp report_update_summary(org, issues_by_id, event) do
    meta = event.metadata || %{}
    from_issue_id = meta["from_issue_id"]
    to_issue_id = meta["to_issue_id"]
    move_type = meta["move_type"]
    changes = changes_from_metadata(event)

    cond do
      is_binary(from_issue_id) and is_binary(to_issue_id) ->
        {:report_move,
         %{
           org: org,
           move_type: move_type,
           from_issue_id: from_issue_id,
           to_issue_id: to_issue_id,
           from_issue: Map.get(issues_by_id || %{}, from_issue_id),
           to_issue: Map.get(issues_by_id || %{}, to_issue_id)
         }}

      map_size(changes) > 0 ->
        {:field_changes,
         build_field_changes(changes, [
           "body",
           "reporter_name",
           "reporter_email",
           "reporter_phone",
           "consent",
           "issue_id",
           "location_id"
         ])}

      true ->
        nil
    end
  end

  defp issue_title(nil, _issue_id), do: "(deleted issue)"
  defp issue_title(issue, _issue_id), do: issue.title

  defp time_link_path(nil, _event), do: nil

  defp time_link_path(org, event) do
    resource = event.resource |> to_string() |> String.split(".") |> List.last()
    type = event.action_type |> to_string()
    record_id = event.record_id |> to_string()

    case {resource, type} do
      {"Report", "create"} -> ~p"/app/#{org.id}/reports/#{record_id}"
      {"Report", "update"} -> ~p"/app/#{org.id}/reports/#{record_id}"
      {"Issue", "create"} -> ~p"/app/#{org.id}/issues/#{record_id}"
      _ -> nil
    end
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

  attr :changes, :list, required: true

  defp field_changes(assigns) do
    ~H"""
    <div class="space-y-3">
      <div :for={c <- @changes} class="rounded-xl border border-base bg-base/40 p-3">
        <div class="text-xs font-semibold text-foreground-soft">{c.label}</div>

        <div class="mt-2 grid gap-3 sm:grid-cols-2">
          <div class="space-y-1">
            <div class="text-[11px] font-medium text-foreground-soft">From</div>
            <div class="max-h-48 overflow-auto rounded-lg border border-base bg-base p-2 whitespace-pre-wrap text-sm leading-6">
              {display_change_value(c.from)}
            </div>
          </div>

          <div class="space-y-1">
            <div class="text-[11px] font-medium text-foreground-soft">To</div>
            <div class="max-h-48 overflow-auto rounded-lg border border-base bg-base p-2 whitespace-pre-wrap text-sm leading-6">
              {display_change_value(c.to)}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp display_change_value(nil), do: "(empty)"
  defp display_change_value(""), do: "(empty)"
  defp display_change_value(other), do: other

  defp changes_from_metadata(event) do
    meta = event.metadata || %{}
    Map.get(meta, "changes") || %{}
  end

  defp build_field_changes(changes, ordered_fields) when is_map(changes) do
    Enum.flat_map(ordered_fields, fn field ->
      case Map.get(changes, field) do
        %{"from" => from, "to" => to} ->
          [
            %{
              field: field,
              label: field_label(field),
              from: from,
              to: to
            }
          ]

        _ ->
          []
      end
    end)
  end

  defp field_label(field) when is_binary(field) do
    case field do
      "title" -> "Title"
      "description" -> "Description"
      "body" -> "Body"
      "reporter_name" -> "Reporter name"
      "reporter_email" -> "Reporter email"
      "reporter_phone" -> "Reporter phone"
      "consent" -> "SMS consent"
      "issue_id" -> "Issue"
      "location_id" -> "Location"
      other -> other |> String.replace("_", " ") |> String.capitalize()
    end
  end
end
