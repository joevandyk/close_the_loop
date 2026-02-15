defmodule CloseTheLoop.Feedback do
  use Ash.Domain,
    otp_app: :close_the_loop

  resources do
    resource CloseTheLoop.Feedback.Location
    resource CloseTheLoop.Feedback.Issue
    resource CloseTheLoop.Feedback.Report
    resource CloseTheLoop.Feedback.IssueUpdate
    resource CloseTheLoop.Feedback.IssueCategory
  end
end
