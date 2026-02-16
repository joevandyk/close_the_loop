defmodule CloseTheLoop.Workers.ResolveReportIssueWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5

  import Ash.Expr

  require Ash.Query
  require Logger

  alias CloseTheLoop.AI
  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.AIContext
  alias CloseTheLoop.Feedback.{Issue, Report}

  @impl true
  def perform(%Oban.Job{args: %{"tenant" => tenant, "report_id" => report_id}} = job) do
    # Debug aid: if we ever see :missing_openai_api_key, confirm whether the worker
    # process can actually read the environment variable. Only logs length, never the key.
    key_len = System.get_env("OPENAI_API_KEY") |> to_string() |> String.length()

    Logger.debug("ResolveReportIssueWorker start",
      tenant: tenant,
      report_id: report_id,
      node: node(),
      openai_key_len: key_len
    )

    with true <- is_binary(tenant),
         {:ok, %Report{} = report} <-
           Feedback.get_report_by_id(report_id,
             tenant: tenant,
             load: [location: [:name, :full_path]]
           ),
         true <- is_nil(report.issue_id) do
      # Location is a strong hint (e.g. men's vs women's locker room), but not a hard constraint:
      # reports can be submitted from a generic kiosk/front-desk location while describing a more
      # specific location in the text.
      candidates = list_candidates(tenant)

      report_context = report_context(report)

      # Give the model a richer view of each candidate issue by including a small
      # sample of recent reports, plus a couple useful fields (status, report count).
      payload = AIContext.candidate_payloads(tenant, candidates)

      case AI.resolve_report_issue(report.body, tenant, report_context, payload) do
        {:ok, {:match, match_id}} when is_binary(match_id) ->
          assign_report_to_issue(job, tenant, report, match_id)

        {:ok, {:new_issue, %{title: title, category: category}}} ->
          create_issue_and_assign(job, tenant, report, title, category)

        {:error, :missing_openai_api_key} ->
          # Persistent failure: mark the report so staff can assign manually.
          _ = Feedback.set_report_ai_resolution_failed(report, tenant: tenant, actor: nil)
          key_len = System.get_env("OPENAI_API_KEY") |> to_string() |> String.length()
          {:discard, "OPENAI_API_KEY is not configured (node=#{node()}, key_len=#{key_len})"}

        {:error, reason} ->
          maybe_fail(job, tenant, report, reason)
      end
    else
      _ ->
        :ok
    end
  end

  defp list_candidates(tenant) when is_binary(tenant) do
    query =
      Issue
      |> Ash.Query.for_read(:non_duplicates, %{})
      |> Ash.Query.filter(expr(status != :fixed))
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(25)
      |> Ash.Query.load([:reporter_count, location: [:name, :full_path]])

    case Ash.read(query, tenant: tenant) do
      {:ok, issues} -> issues
      _ -> []
    end
  end

  defp assign_report_to_issue(job, tenant, %Report{} = report, issue_id) do
    case Feedback.assign_report_issue(report, %{issue_id: issue_id}, tenant: tenant, actor: nil) do
      {:ok, _report} ->
        :ok

      {:error, reason} ->
        maybe_fail(job, tenant, report, reason)
    end
  end

  defp create_issue_and_assign(job, tenant, %Report{} = report, title, category) do
    attrs = %{
      location_id: report.location_id,
      title: title,
      description: report.body,
      normalized_description: report.normalized_body,
      status: :new,
      category: category
    }

    with {:ok, %Issue{} = issue} <- Feedback.create_issue(attrs, tenant: tenant, actor: nil) do
      assign_report_to_issue(job, tenant, report, issue.id)
    else
      {:error, reason} ->
        maybe_fail(job, tenant, report, reason)
    end
  end

  defp maybe_fail(%Oban.Job{} = job, tenant, %Report{} = report, reason) do
    # When retries are exhausted, record the failure for UI visibility.
    if job.attempt >= job.max_attempts do
      _ = Feedback.set_report_ai_resolution_failed(report, tenant: tenant, actor: nil)
      :ok
    else
      {:error, reason}
    end
  end

  defp location_display_name(nil), do: ""

  defp location_display_name(loc) do
    loc.full_path || loc.name
  end

  defp report_context(%Report{} = report) do
    [
      location_display_name(report.location) |> line_if_present("Location"),
      report.source |> to_string() |> String.trim() |> line_if_present("Source"),
      iso8601(report.inserted_at) |> line_if_present("Reported at")
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
  end

  defp line_if_present("", _label), do: ""
  defp line_if_present(nil, _label), do: ""

  defp line_if_present(val, label) when is_binary(val) do
    val = String.trim(val)
    if val == "", do: "", else: "#{label}: #{val}"
  end

  defp iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso8601(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp iso8601(other) when is_binary(other), do: other
  defp iso8601(_), do: ""
end
