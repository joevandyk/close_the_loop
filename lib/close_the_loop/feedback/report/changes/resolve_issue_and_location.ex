defmodule CloseTheLoop.Feedback.Report.Changes.ResolveIssueAndLocation do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Feedback.Issue
  alias CloseTheLoop.Feedback.Report
  alias CloseTheLoop.Workers.ResolveReportIssueWorker

  @impl true
  def change(changeset, _opts, context) do
    tenant = context.tenant || changeset.tenant

    issue_id = Ash.Changeset.get_attribute(changeset, :issue_id)
    location_id = Ash.Changeset.get_attribute(changeset, :location_id)
    normalized_body = Ash.Changeset.get_attribute(changeset, :normalized_body)

    cond do
      is_nil(tenant) ->
        # All report creates are tenant-scoped.
        Ash.Changeset.add_error(changeset, field: :location_id, message: "Missing tenant")

      not is_nil(issue_id) ->
        validate_and_force_issue_location(changeset, tenant, issue_id, location_id)

      is_nil(location_id) ->
        Ash.Changeset.add_error(changeset, field: :location_id, message: "Location is required")

      normalized_body in [nil, ""] ->
        # Don't query or create issues when the report body is empty/invalid.
        changeset

      true ->
        # Option B: save the report immediately, then let a background job call OpenAI
        # to either match an existing issue or create a new one. This keeps the write
        # path fast and avoids creating issues that we immediately merge away.
        changeset
        |> Ash.Changeset.force_change_attribute(:ai_resolution_status, :pending)
        |> Ash.Changeset.after_transaction(fn _changeset, result ->
          case result do
            {:ok, %Report{} = report} when is_nil(report.issue_id) ->
              _ =
                Oban.insert(
                  ResolveReportIssueWorker.new(%{
                    tenant: tenant,
                    report_id: report.id
                  })
                )

              result

            _ ->
              result
          end
        end)
    end
  end

  defp validate_and_force_issue_location(changeset, tenant, issue_id, location_id) do
    case Ash.get(Issue, issue_id, tenant: tenant) do
      {:ok, %Issue{} = issue} ->
        if location_id && to_string(location_id) != to_string(issue.location_id) do
          Ash.Changeset.add_error(changeset,
            field: :issue_id,
            message: "Selected issue does not match the location"
          )
        else
          changeset
          |> Ash.Changeset.force_change_attribute(:issue_id, issue.id)
          |> Ash.Changeset.force_change_attribute(:location_id, issue.location_id)
        end

      _ ->
        Ash.Changeset.add_error(changeset, field: :issue_id, message: "Issue not found")
    end
  end
end
