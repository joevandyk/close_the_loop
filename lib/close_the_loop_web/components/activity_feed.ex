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
  attr :current_user, :any, default: nil
  attr :org, :any, default: nil

  attr :title, :string, default: "Activity"
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
                    <span class="font-medium truncate">{event_title(e)}</span>
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
                  <span class="font-medium truncate">{event_title(e)}</span>
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

            <div
              :if={summary = event_summary(@org, e)}
              class="whitespace-pre-wrap text-sm leading-6 text-foreground"
            >
              {summary}
            </div>
          </div>
        </li>
      </ul>
    </div>
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
    data = event.data || %{}

    cond do
      not is_nil(issue_status_change(event)) ->
        "Status changed"

      Map.has_key?(data, "status") ->
        "Status changed"

      Map.has_key?(data, "title") or Map.has_key?(data, "description") ->
        "Details updated"

      true ->
        "Issue updated"
    end
  end

  defp report_update_title(event) do
    changed = event.changed_attributes || %{}
    issue_change = Map.get(changed, "issue_id")
    location_change = Map.get(changed, "location_id")

    if is_nil(issue_change) and is_nil(location_change) do
      "Report updated"
    else
      "Report reassigned"
    end
  end

  defp event_summary(_org, event) do
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
        report_update_summary(event)

      _ ->
        nil
    end
  end

  defp issue_update_summary(event) do
    data = event.data || %{}

    case issue_status_change(event) do
      {from, to} ->
        "Status: #{issue_status_label(from)} -> #{issue_status_label(to)}"

      nil ->
        cond do
          status = Map.get(data, "status") ->
            "Status set to #{issue_status_label(status)}"

          Map.has_key?(data, "title") or Map.has_key?(data, "description") ->
            fields =
              ["title", "description"]
              |> Enum.filter(&Map.has_key?(data, &1))

            "Updated: #{Enum.join(fields, ", ")}"

          true ->
            nil
        end
    end
  end

  defp issue_status_change(event) do
    metadata = Map.get(event, :metadata) || %{}
    changes = Map.get(metadata, "changes") || %{}

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

  defp report_update_summary(event) do
    changed = event.changed_attributes || %{}
    issue_changed? = Map.has_key?(changed, "issue_id")
    location_changed? = Map.has_key?(changed, "location_id")

    cond do
      issue_changed? and location_changed? ->
        "Moved to a different issue (and location)."

      issue_changed? ->
        "Moved to a different issue."

      location_changed? ->
        "Location updated."

      true ->
        nil
    end
  end

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
end
