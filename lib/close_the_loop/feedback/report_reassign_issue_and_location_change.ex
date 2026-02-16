defmodule CloseTheLoop.Feedback.Report.Changes.ReassignIssueAndLocation do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Feedback.Issue

  @impl true
  def change(changeset, _opts, context) do
    issue_id = Ash.Changeset.get_argument(changeset, :issue_id)
    tenant = context.tenant || changeset.tenant

    case Ash.get(Issue, issue_id, tenant: tenant) do
      {:ok, %Issue{} = issue} ->
        changeset
        |> Ash.Changeset.force_change_attribute(:issue_id, issue.id)
        |> Ash.Changeset.force_change_attribute(:location_id, issue.location_id)

      _ ->
        Ash.Changeset.add_error(changeset,
          field: :issue_id,
          message: "Issue not found"
        )
    end
  end
end
