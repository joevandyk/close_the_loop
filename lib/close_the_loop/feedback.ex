defmodule CloseTheLoop.Feedback do
  use Ash.Domain,
    otp_app: :close_the_loop,
    extensions: [AshPhoenix]

  alias CloseTheLoop.Feedback.IssueUpdateInput

  resources do
    resource CloseTheLoop.Feedback.Location do
      define :get_location_by_id, action: :read, get_by: [:id]
      define :list_locations, action: :read

      define :create_location, action: :create
      define :update_location, action: :update
      define :destroy_location, action: :destroy
    end

    resource CloseTheLoop.Feedback.Issue do
      define :get_issue_by_id, action: :read, get_by: [:id]
      define :list_issues, action: :read
      define :list_non_duplicate_issues, action: :non_duplicates

      define :create_issue, action: :create
      define :set_issue_status, action: :set_status
      define :edit_issue_details, action: :edit_details
      define :mark_issue_duplicate, action: :mark_duplicate
      define :destroy_issue, action: :destroy
    end

    resource CloseTheLoop.Feedback.Report do
      define :get_report_by_id, action: :read, get_by: [:id]
      define :list_reports, action: :read

      define :create_report, action: :create
      define :edit_report_details, action: :edit_details
      define :assign_report_issue, action: :assign_issue
      define :reassign_report_issue, action: :reassign_issue
      define :set_report_ai_resolution_failed, action: :set_ai_resolution_failed
    end

    resource CloseTheLoop.Feedback.IssueUpdate do
      define :list_issue_updates, action: :read
      define :create_issue_update, action: :create
    end

    resource CloseTheLoop.Feedback.IssueComment do
      define :list_issue_comments, action: :read
      define :create_issue_comment, action: :create
    end

    resource CloseTheLoop.Feedback.IssueCategory do
      define :get_issue_category_by_id, action: :read, get_by: [:id]
      define :list_issue_categories, action: :read

      define :create_issue_category, action: :create
      define :update_issue_category, action: :update
      define :destroy_issue_category, action: :destroy
    end
  end

  # Convenience wrapper for the issue detail UI: one submission can change the
  # issue status and/or create an internal comment (each tracked as its own event).
  def form_to_add_issue_update(issue, opts) do
    tenant = Keyword.fetch!(opts, :tenant)
    actor = Keyword.fetch!(opts, :actor)

    AshPhoenix.Form.for_create(IssueUpdateInput, :submit,
      as: "issue_update",
      id: "issue_update",
      tenant: tenant,
      actor: actor,
      params: %{"status" => to_string(issue.status), "comment_body" => ""},
      prepare_source: fn changeset ->
        Ash.Changeset.put_context(changeset, :issue, issue)
      end
    )
    |> Phoenix.Component.to_form()
  end

  def add_issue_update(issue, params, opts) when is_map(params) do
    form = form_to_add_issue_update(issue, opts)
    AshPhoenix.Form.submit(form, params: params)
  end
end
