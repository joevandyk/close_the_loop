defmodule CloseTheLoop.Workers.DedupeIssueWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5

  import Ash.Expr

  alias CloseTheLoop.AI
  alias CloseTheLoop.Feedback.{Issue, Report}

  require Ash.Query

  @impl true
  def perform(%Oban.Job{args: %{"tenant" => tenant, "issue_id" => issue_id}}) do
    with {:ok, %Issue{} = issue} <- Ash.get(Issue, issue_id, tenant: tenant),
         true <- issue.status != :fixed,
         true <- is_nil(issue.duplicate_of_issue_id) do
      candidates = list_candidates(tenant, issue)

      if candidates == [] do
        :ok
      else
        payload =
          Enum.map(candidates, fn c ->
            %{id: c.id, title: c.title, description: c.description}
          end)

        case AI.match_duplicate_issue(issue.description, payload) do
          {:ok, nil} ->
            :ok

          {:ok, match_id} when is_binary(match_id) ->
            merge_into_existing_issue(tenant, issue, match_id)

          {:error, :missing_openai_api_key} ->
            # Treat missing config as non-retryable to avoid noisy retries in dev/test.
            {:discard, "OPENAI_API_KEY is not configured"}

          {:error, reason} ->
            {:error, reason}
        end
      end
    else
      _ ->
        :ok
    end
  end

  defp list_candidates(tenant, %Issue{} = issue) do
    query =
      Issue
      |> Ash.Query.filter(
        expr(
          location_id == ^issue.location_id and status != :fixed and is_nil(duplicate_of_issue_id) and
            id != ^issue.id
        )
      )
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(15)

    case Ash.read(query, tenant: tenant) do
      {:ok, issues} -> issues
      _ -> []
    end
  end

  defp merge_into_existing_issue(tenant, %Issue{} = issue, match_id) do
    # Re-fetch the issue to reduce races (e.g. another worker already marked it).
    with {:ok, %Issue{} = issue} <- Ash.get(Issue, issue.id, tenant: tenant),
         true <- is_nil(issue.duplicate_of_issue_id) do
      _ = move_reports(tenant, issue.id, match_id)

      case Ash.update(issue, %{duplicate_of_issue_id: match_id},
             action: :mark_duplicate,
             tenant: tenant
           ) do
        {:ok, _} -> :ok
        {:error, err} -> {:error, err}
      end
    else
      _ ->
        :ok
    end
  end

  defp move_reports(tenant, from_issue_id, to_issue_id) do
    query =
      Report
      |> Ash.Query.filter(expr(issue_id == ^from_issue_id))

    case Ash.read(query, tenant: tenant) do
      {:ok, reports} ->
        Enum.each(reports, fn report ->
          _ =
            Ash.update(report, %{issue_id: to_issue_id},
              action: :reassign_issue,
              tenant: tenant
            )
        end)

        :ok

      _ ->
        :ok
    end
  end
end
