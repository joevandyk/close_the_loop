defmodule CloseTheLoop.Feedback do
  use Ash.Domain,
    otp_app: :close_the_loop

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
      define :reassign_report_issue, action: :reassign_issue
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
end
