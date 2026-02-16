defmodule CloseTheLoop.Workers.DedupeIssueWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5

  import Ash.Expr

  alias CloseTheLoop.AI
  alias CloseTheLoop.Feedback.AIContext
  alias CloseTheLoop.Feedback.{Issue, Report}

  require Ash.Query

  @impl true
  def perform(%Oban.Job{args: %{"tenant" => tenant, "issue_id" => issue_id}}) do
    with {:ok, %Issue{} = issue} <-
           Ash.get(Issue, issue_id,
             tenant: tenant,
             load: [location: [:name, :full_path]]
           ),
         true <- issue.status != :fixed,
         true <- is_nil(issue.duplicate_of_issue_id) do
      candidates = list_candidates(tenant, issue)

      if candidates == [] do
        :ok
      else
        # Include the issue's own recent reports to make matching more accurate.
        reports_by_issue_id = AIContext.recent_reports_by_issue_id(tenant, [issue.id], 10, [])
        self_reports = Map.get(reports_by_issue_id, issue.id, [])

        new_issue_text =
          case issue.location do
            nil -> issue.description
            loc -> "Location: #{location_display_name(loc)}\n\n#{issue.description}"
          end
          |> append_recent_reports(self_reports)

        payload = AIContext.candidate_payloads(tenant, candidates)

        case AI.match_duplicate_issue(new_issue_text, payload) do
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
        expr(status != :fixed and is_nil(duplicate_of_issue_id) and id != ^issue.id)
      )
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(25)
      |> Ash.Query.load([:reporter_count, location: [:name, :full_path]])

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

  defp location_display_name(nil), do: ""

  defp location_display_name(loc) do
    loc.full_path || loc.name
  end

  defp append_recent_reports(text, []), do: text

  defp append_recent_reports(text, reports) when is_list(reports) do
    reports_block =
      reports
      |> Enum.map(fn r ->
        dt = r[:inserted_at] |> iso8601()
        src = r[:source] |> to_string() |> String.trim()
        loc = r[:location] |> to_string() |> String.trim()

        meta =
          [dt, src, loc]
          |> Enum.reject(&(&1 == ""))
          |> Enum.join(" | ")

        body = r[:body] |> to_string() |> normalize_whitespace() |> truncate(280)

        if meta == "" do
          "- #{body}"
        else
          "- (#{meta}) #{body}"
        end
      end)
      |> Enum.join("\n")

    String.trim(text) <> "\n\nRECENT REPORTS ON THIS ISSUE:\n" <> reports_block
  end

  defp normalize_whitespace(text) do
    text
    |> to_string()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp truncate(text, max_chars) when is_integer(max_chars) and max_chars > 0 do
    text = to_string(text)

    if String.length(text) > max_chars do
      String.slice(text, 0, max_chars) <> "..."
    else
      text
    end
  end

  defp iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp iso8601(other) when is_binary(other), do: other
  defp iso8601(_), do: ""

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
