defmodule CloseTheLoop.Feedback.AIContext do
  @moduledoc false

  # Helpers for building token-safe, privacy-aware AI prompt payloads.
  #
  # We intentionally:
  # - include report bodies (they are the best signal for matching),
  # - exclude reporter PII fields (name/email/phone),
  # - cap how many reports we attach per issue to avoid runaway context size.

  import Ash.Expr

  alias CloseTheLoop.Feedback.Report

  require Ash.Query

  @default_reports_per_issue 10
  @default_max_concurrency 5

  @spec candidate_payloads(binary(), list(struct()), keyword()) :: list(map())
  def candidate_payloads(tenant, issues, opts \\ []) when is_binary(tenant) and is_list(issues) do
    reports_per_issue = Keyword.get(opts, :reports_per_issue, @default_reports_per_issue)
    include_reports? = Keyword.get(opts, :include_reports?, true)

    reports_by_issue_id =
      if include_reports? and reports_per_issue > 0 and issues != [] do
        issue_ids = Enum.map(issues, & &1.id)
        recent_reports_by_issue_id(tenant, issue_ids, reports_per_issue, opts)
      else
        %{}
      end

    Enum.map(issues, fn issue ->
      %{
        id: issue.id,
        title: issue.title,
        description: issue.description,
        status: Map.get(issue, :status),
        inserted_at: Map.get(issue, :inserted_at),
        updated_at: Map.get(issue, :updated_at),
        reporter_count: Map.get(issue, :reporter_count),
        location: location_display_name(Map.get(issue, :location)),
        recent_reports: Map.get(reports_by_issue_id, issue.id, [])
      }
    end)
  end

  @spec recent_reports_by_issue_id(binary(), list(binary()), pos_integer(), keyword()) ::
          %{optional(binary()) => list(map())}
  def recent_reports_by_issue_id(_tenant, [], _per_issue_limit, _opts), do: %{}

  def recent_reports_by_issue_id(tenant, issue_ids, per_issue_limit, opts)
      when is_binary(tenant) and is_list(issue_ids) and is_integer(per_issue_limit) and
             per_issue_limit > 0 do
    max_concurrency = Keyword.get(opts, :max_concurrency, @default_max_concurrency)

    issue_ids
    |> Task.async_stream(
      fn issue_id ->
        {issue_id, list_recent_reports_for_issue(tenant, issue_id, per_issue_limit)}
      end,
      max_concurrency: max_concurrency,
      timeout: :infinity
    )
    |> Enum.reduce(%{}, fn
      {:ok, {issue_id, reports}}, acc ->
        Map.put(acc, issue_id, reports)

      _other, acc ->
        acc
    end)
  end

  defp list_recent_reports_for_issue(tenant, issue_id, per_issue_limit) do
    query =
      Report
      |> Ash.Query.for_read(:read, %{})
      |> Ash.Query.filter(expr(issue_id == ^issue_id))
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(per_issue_limit)
      # Only include fields we want the model to see (avoid reporter_* PII).
      |> Ash.Query.select([:id, :body, :source, :inserted_at, :location_id])
      |> Ash.Query.load(location: [:name, :full_path])

    case Ash.read(query, tenant: tenant) do
      {:ok, reports} ->
        Enum.map(reports, fn report ->
          %{
            id: report.id,
            inserted_at: report.inserted_at,
            source: report.source,
            location: location_display_name(Map.get(report, :location)),
            body: report.body
          }
        end)

      _ ->
        []
    end
  end

  defp location_display_name(nil), do: ""

  defp location_display_name(loc) do
    loc.full_path || loc.name
  end
end

defmodule CloseTheLoop.Feedback.AIContext do
  @moduledoc false

  # Helpers for building token-safe, privacy-aware AI prompt payloads.
  #
  # We intentionally:
  # - include report bodies (they are the best signal for matching),
  # - exclude reporter PII fields (name/email/phone),
  # - cap how many reports we attach per issue to avoid runaway context size.

  import Ash.Expr

  alias CloseTheLoop.Feedback.{Issue, Report}

  require Ash.Query

  @default_reports_per_issue 10
  @default_max_concurrency 5

  @spec candidate_payloads(binary(), list(struct()), keyword()) :: list(map())
  def candidate_payloads(tenant, issues, opts \\ []) when is_binary(tenant) and is_list(issues) do
    issues = Enum.filter(issues, &match?(%Issue{}, &1))

    reports_per_issue = Keyword.get(opts, :reports_per_issue, @default_reports_per_issue)
    include_reports? = Keyword.get(opts, :include_reports?, true)

    reports_by_issue_id =
      if include_reports? and reports_per_issue > 0 and issues != [] do
        issue_ids = Enum.map(issues, & &1.id)
        recent_reports_by_issue_id(tenant, issue_ids, reports_per_issue, opts)
      else
        %{}
      end

    Enum.map(issues, fn issue ->
      %{
        id: issue.id,
        title: issue.title,
        description: issue.description,
        status: issue.status,
        inserted_at: issue.inserted_at,
        updated_at: issue.updated_at,
        reporter_count: Map.get(issue, :reporter_count),
        location: location_display_name(Map.get(issue, :location)),
        recent_reports: Map.get(reports_by_issue_id, issue.id, [])
      }
    end)
  end

  @spec recent_reports_by_issue_id(binary(), list(binary()), pos_integer(), keyword()) ::
          %{optional(binary()) => list(map())}
  def recent_reports_by_issue_id(_tenant, [], _per_issue_limit, _opts), do: %{}

  def recent_reports_by_issue_id(tenant, issue_ids, per_issue_limit, opts)
      when is_binary(tenant) and is_list(issue_ids) and is_integer(per_issue_limit) and
             per_issue_limit > 0 do
    max_concurrency = Keyword.get(opts, :max_concurrency, @default_max_concurrency)

    issue_ids
    |> Task.async_stream(
      fn issue_id ->
        {issue_id, list_recent_reports_for_issue(tenant, issue_id, per_issue_limit)}
      end,
      max_concurrency: max_concurrency,
      timeout: :infinity
    )
    |> Enum.reduce(%{}, fn
      {:ok, {issue_id, reports}}, acc ->
        Map.put(acc, issue_id, reports)

      _other, acc ->
        acc
    end)
  end

  defp list_recent_reports_for_issue(tenant, issue_id, per_issue_limit) do
    query =
      Report
      |> Ash.Query.for_read(:read, %{})
      |> Ash.Query.filter(expr(issue_id == ^issue_id))
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(per_issue_limit)
      # Only include fields we want the model to see (avoid reporter_* PII).
      |> Ash.Query.select([:id, :body, :source, :inserted_at, :location_id])
      |> Ash.Query.load(location: [:name, :full_path])

    case Ash.read(query, tenant: tenant) do
      {:ok, reports} ->
        Enum.map(reports, fn report ->
          %{
            id: report.id,
            inserted_at: report.inserted_at,
            source: report.source,
            location: location_display_name(Map.get(report, :location)),
            body: report.body
          }
        end)

      _ ->
        []
    end
  end

  defp location_display_name(nil), do: ""

  defp location_display_name(loc) do
    loc.full_path || loc.name
  end
end
