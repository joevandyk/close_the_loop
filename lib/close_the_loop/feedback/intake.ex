defmodule CloseTheLoop.Feedback.Intake do
  @moduledoc """
  Entry points for reporter submissions (QR + SMS).

  MVP dedupe is deterministic: same location + same normalized body + not fixed.
  We also run best-effort AI categorization + dedupe via Oban.
  """

  import Ash.Expr

  alias CloseTheLoop.Feedback.{Issue, Report}
  alias CloseTheLoop.Feedback.Text
  alias CloseTheLoop.Messaging.Phone

  require Ash.Query

  @type source :: :qr | :sms | :manual

  @spec submit_report(String.t(), Ash.UUID.t(), map()) ::
          {:ok, %{issue: Issue.t(), report: Report.t()}} | {:error, term()}
  def submit_report(tenant, location_id, %{body: body} = attrs) when is_binary(tenant) do
    normalized = Text.normalize_for_dedupe(body)

    reporter_name =
      blank_to_nil(Map.get(attrs, :reporter_name) || Map.get(attrs, "reporter_name"))

    reporter_email =
      blank_to_nil(Map.get(attrs, :reporter_email) || Map.get(attrs, "reporter_email"))

    with :ok <- validate_email(reporter_email),
         {:ok, reporter_phone} <- Phone.normalize_e164(Map.get(attrs, :reporter_phone)),
         {:ok, issue} <- get_or_create_issue(tenant, location_id, body, normalized),
         {:ok, report} <-
           Ash.create(
             Report,
             %{
               location_id: location_id,
               issue_id: issue.id,
               body: body,
               normalized_body: normalized,
               source: Map.fetch!(attrs, :source),
               reporter_name: reporter_name,
               reporter_email: reporter_email,
               reporter_phone: reporter_phone,
               consent: Map.get(attrs, :consent, false) and not is_nil(reporter_phone)
             },
             tenant: tenant
           ) do
      {:ok, %{issue: issue, report: report}}
    end
  end

  defp get_or_create_issue(tenant, location_id, body, normalized) do
    query =
      Issue
      |> Ash.Query.filter(
        expr(
          location_id == ^location_id and status != :fixed and
            normalized_description == ^normalized and is_nil(duplicate_of_issue_id)
        )
      )
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(1)

    case Ash.read_one(query, tenant: tenant) do
      {:ok, %Issue{} = issue} ->
        {:ok, issue}

      {:ok, nil} ->
        with {:ok, issue} <-
               Ash.create(
                 Issue,
                 %{
                   location_id: location_id,
                   title: build_title(body),
                   description: body,
                   normalized_description: normalized,
                   status: :new
                 },
                 tenant: tenant
               ) do
          # Best-effort async AI categorization (job discards if OPENAI_API_KEY missing).
          _ =
            Oban.insert(
              CloseTheLoop.Workers.CategorizeIssueWorker.new(%{
                tenant: tenant,
                issue_id: issue.id
              })
            )

          # Best-effort async AI dedupe: if a similar open issue already exists at this location,
          # we can merge the newly created issue into the existing one.
          _ =
            Oban.insert(
              CloseTheLoop.Workers.DedupeIssueWorker.new(%{
                tenant: tenant,
                issue_id: issue.id
              })
            )

          {:ok, issue}
        end

      {:error, _} = err ->
        err
    end
  end

  defp build_title(body) do
    body
    |> String.trim()
    |> String.slice(0, 80)
    |> case do
      "" -> "New report"
      title -> title
    end
  end

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(val) do
    val = val |> to_string() |> String.trim()
    if val == "", do: nil, else: val
  end

  # Intentionally loose validation: we want to avoid blocking legitimate addresses
  # while still catching obvious typos that hurt follow-ups.
  defp validate_email(nil), do: :ok

  defp validate_email(email) when is_binary(email) do
    if Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email) do
      :ok
    else
      {:error, "Email address looks invalid"}
    end
  end
end
