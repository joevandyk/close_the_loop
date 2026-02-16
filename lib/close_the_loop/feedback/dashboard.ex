defmodule CloseTheLoop.Feedback.Dashboard do
  @moduledoc false

  import Ash.Expr

  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.{Issue, IssueComment, Report}

  require Ash.Query

  def load(tenant) when is_binary(tenant) do
    with {:ok, stats} <- stats(tenant),
         {:ok, recent_issues} <- recent_issues(tenant),
         {:ok, recent_reports} <- recent_reports(tenant),
         {:ok, recent_comments} <- recent_comments(tenant),
         {:ok, recent_updates} <- recent_updates(tenant) do
      {:ok,
       %{
         stats: stats,
         recent_issues: recent_issues,
         recent_reports: recent_reports,
         recent_comments: recent_comments,
         recent_updates: recent_updates
       }}
    end
  end

  def stats(tenant) when is_binary(tenant) do
    with {:ok, issues_total} <- count_issues(tenant, nil),
         {:ok, issues_new} <- count_issues(tenant, :new),
         {:ok, issues_in_progress} <- count_issues(tenant, :in_progress),
         {:ok, issues_fixed} <- count_issues(tenant, :fixed),
         {:ok, reports_total} <- Ash.count(Report, tenant: tenant),
         {:ok, comments_total} <- Ash.count(IssueComment, tenant: tenant) do
      {:ok,
       %{
         issues_total: issues_total,
         issues_new: issues_new,
         issues_in_progress: issues_in_progress,
         issues_fixed: issues_fixed,
         reports_total: reports_total,
         comments_total: comments_total
       }}
    end
  end

  def recent_issues(tenant) when is_binary(tenant) do
    Feedback.list_non_duplicate_issues(
      tenant: tenant,
      query: [
        sort: [inserted_at: :desc],
        limit: 8
      ],
      load: [:reporter_count, location: [:name, :full_path]]
    )
  end

  def recent_reports(tenant) when is_binary(tenant) do
    Feedback.list_reports(
      tenant: tenant,
      query: [sort: [updated_at: :desc, inserted_at: :desc], limit: 8],
      load: [location: [:name, :full_path]]
    )
  end

  def recent_comments(tenant) when is_binary(tenant) do
    Feedback.list_issue_comments(
      tenant: tenant,
      query: [sort: [updated_at: :desc, inserted_at: :desc], limit: 6],
      load: [issue: [:title]]
    )
  end

  def recent_updates(tenant) when is_binary(tenant) do
    Feedback.list_issue_updates(
      tenant: tenant,
      query: [sort: [inserted_at: :desc], limit: 6],
      load: [issue: [:title]]
    )
  end

  defp count_issues(tenant, status) when is_binary(tenant) do
    query =
      Issue
      |> Ash.Query.filter(expr(is_nil(duplicate_of_issue_id)))

    query =
      if is_nil(status) do
        query
      else
        Ash.Query.filter(query, expr(status == ^status))
      end

    Ash.count(query, tenant: tenant)
  end
end
