defmodule CloseTheLoop.Feedback.IssueUpdateInput.Changes.NormalizeAndValidate do
  @moduledoc false

  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    issue = changeset.context[:issue]

    status = Ash.Changeset.get_argument(changeset, :status)
    comment_body = Ash.Changeset.get_argument(changeset, :comment_body)

    issue_status =
      case issue do
        %{status: status} -> status
        _ -> nil
      end

    status_changed? = not is_nil(status) and not is_nil(issue_status) and status != issue_status

    cond do
      not status_changed? and (is_nil(comment_body) or comment_body == "") ->
        Ash.Changeset.add_error(changeset,
          field: :comment_body,
          message: "Add a comment or change the status"
        )

      true ->
        changeset
    end
  end
end
