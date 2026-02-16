alias CloseTheLoop.{Feedback, Tenants}
alias CloseTheLoop.Feedback.Text
alias CloseTheLoop.Workers.ResolveReportIssueWorker

IO.puts("\n== AI report resolution smoke test ==")

{:ok, orgs} = Tenants.list_organizations()

org =
  case orgs do
    [first | _] -> first
    [] -> raise "No organizations found. Run seeds or create an org first."
  end

tenant = org.tenant_schema
IO.puts("Using tenant: #{tenant}")

{:ok, locations} = Feedback.list_locations(tenant: tenant, query: [limit: 1, sort: [inserted_at: :asc]])

location =
  case locations do
    [loc | _] ->
      loc

    [] ->
      {:ok, loc} =
        Feedback.create_location(
          %{
            name: "Smoke Test Location",
            full_path: "Smoke Test Location"
          },
          tenant: tenant,
          actor: nil
        )

      loc
  end

IO.puts("Using location: #{location.full_path || location.name} (#{location.id})")

# Create an existing open issue that the report should match.
issue_desc = "The men's showers only have cold water again."

{:ok, existing_issue} =
  Feedback.create_issue(
    %{
      location_id: location.id,
      title: "Cold water in men's showers",
      description: issue_desc,
      normalized_description: Text.normalize_for_dedupe(issue_desc),
      status: :new
    },
    tenant: tenant,
    actor: nil
  )

IO.puts("Created candidate issue: #{existing_issue.id} (#{existing_issue.title})")

# Create a new report. It should be saved with issue_id=nil and processed by AI.
report_body = "Men's showers are cold again — no hot water."

{:ok, report} =
  Feedback.create_report(
    %{
      body: report_body,
      source: :qr,
      location_id: location.id,
      reporter_name: "Smoke Test",
      consent: false
    },
    tenant: tenant,
    actor: nil
  )

IO.puts("Created report: #{report.id}")
IO.puts("Initial report.issue_id: #{inspect(report.issue_id)}")
IO.puts("Initial report.ai_resolution_status: #{inspect(report.ai_resolution_status)}")

# Run the worker inline so the script deterministically hits OpenAI.
job =
  struct(Oban.Job, %{
    args: %{"tenant" => tenant, "report_id" => report.id},
    attempt: 1,
    max_attempts: 5
  })

IO.puts("\nCalling ResolveReportIssueWorker (this should hit OpenAI)...")

case ResolveReportIssueWorker.perform(job) do
  :ok ->
    :ok

  other ->
    IO.puts("Worker returned: #{inspect(other)}")
end

{:ok, report_after} =
  Feedback.get_report_by_id(report.id,
    tenant: tenant,
    load: [issue: [:title, :category], location: [:name, :full_path]]
  )

IO.puts("\nAfter worker:")
IO.puts("report.issue_id: #{inspect(report_after.issue_id)}")
IO.puts("report.ai_resolution_status: #{inspect(report_after.ai_resolution_status)}")
IO.puts("report.issue.title: #{inspect(report_after.issue && report_after.issue.title)}")
IO.puts("report.issue.category: #{inspect(report_after.issue && report_after.issue.category)}")

expected = to_string(existing_issue.id)
actual = report_after.issue_id && to_string(report_after.issue_id)

cond do
  actual == expected ->
    IO.puts("\nOK: report was matched to the existing issue.")

  is_binary(actual) and report_after.ai_resolution_status == :resolved ->
    IO.puts(
      "\nOK: OpenAI resolved the report, but created a new issue instead of matching (issue_id=#{actual})."
    )

  true ->
    raise "AI resolution failed: expected assigned issue, got #{inspect(actual)}"
end

