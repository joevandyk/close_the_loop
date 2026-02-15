defmodule CloseTheLoop.Workers.CategorizeIssueWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5

  alias CloseTheLoop.AI
  alias CloseTheLoop.Feedback.Issue

  @impl true
  def perform(%Oban.Job{args: %{"tenant" => tenant, "issue_id" => issue_id}}) do
    with {:ok, %Issue{} = issue} <- Ash.get(Issue, issue_id, tenant: tenant),
         true <- is_nil(issue.category) or issue.category == "" do
      case AI.categorize_issue(issue.description, tenant) do
        {:ok, category} ->
          _ = Ash.update(issue, %{category: category}, tenant: tenant)
          :ok

        {:error, :missing_openai_api_key} ->
          # Treat missing config as non-retryable to avoid noisy retries in dev.
          {:discard, "OPENAI_API_KEY is not configured"}

        {:error, reason} ->
          {:error, reason}
      end
    else
      _ ->
        :ok
    end
  end
end
