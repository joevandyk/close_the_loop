defmodule CloseTheLoop.Scripts.AIReportResolutionSmoke do
  @moduledoc false

  alias CloseTheLoop.{Feedback, Tenants}
  alias CloseTheLoop.Feedback.{AIContext, Text}
  alias CloseTheLoop.Workers.ResolveReportIssueWorker

  import Ash.Expr
  require Ash.Query

  def run do
    IO.puts("\n== AI report resolution smoke test (grouping) ==")

    api_key = System.get_env("OPENAI_API_KEY") |> to_string() |> String.trim()

    if api_key == "" do
      IO.puts("""

      OPENAI_API_KEY is not set. This script uses real OpenAI.

      Run:
        OPENAI_API_KEY=... mix run priv/scripts/ai_report_resolution_smoke.exs
      """)

      System.halt(1)
    end

    run_id = System.unique_integer([:positive]) |> Integer.to_string()
    prefix = "[AI Smoke #{run_id}]"

    IO.puts("Run id: #{run_id}")

    {:ok, orgs} = Tenants.list_organizations()

    org =
      case orgs do
        [first | _] -> first
        [] -> raise "No organizations found. Run seeds or create an org first."
      end

    tenant = org.tenant_schema
    IO.puts("Using tenant: #{tenant}")

    location_a = get_or_create_location!(tenant, "#{prefix} Location A", "#{prefix} Location A")
    location_b = get_or_create_location!(tenant, "#{prefix} Location B", "#{prefix} Location B")

    womens = get_or_create_location!(tenant, "#{prefix} Women's Locker Room", "#{prefix} Women's Locker Room")
    mens = get_or_create_location!(tenant, "#{prefix} Men's Locker Room", "#{prefix} Men's Locker Room")
    front_desk = get_or_create_location!(tenant, "#{prefix} Front Desk", "#{prefix} Front Desk")

    IO.puts("Using location A: #{location_a.full_path || location_a.name} (#{location_a.id})")
    IO.puts("Using location B: #{location_b.full_path || location_b.name} (#{location_b.id})")
    IO.puts("Using women's locker room: #{womens.full_path || womens.name} (#{womens.id})")
    IO.puts("Using men's locker room: #{mens.full_path || mens.name} (#{mens.id})")
    IO.puts("Using front desk: #{front_desk.full_path || front_desk.name} (#{front_desk.id})")

    # We create issues with intentionally vague descriptions. The only reliable discriminator
    # is a marker string that appears in the *existing issue's past reports*.
    #
    # This ensures our "candidate issue includes recent reports" change is actually exercised.
    issue_desc_vague = "Investigate recurring customer complaints. See reports for details."

    marker_a = "SMOKE_KEY_A=#{run_id}"
    marker_b = "SMOKE_KEY_B=#{run_id}"
    marker_c = "SMOKE_KEY_C=#{run_id}"
    marker_w = "SMOKE_KEY_W=#{run_id}"
    marker_m = "SMOKE_KEY_M=#{run_id}"

    {:ok, issue_a} =
      Feedback.create_issue(
        %{
          location_id: location_a.id,
          title: "#{prefix} Vague issue A",
          description: issue_desc_vague,
          normalized_description: Text.normalize_for_dedupe(issue_desc_vague),
          status: :new
        },
        tenant: tenant,
        actor: nil
      )

    {:ok, issue_b} =
      Feedback.create_issue(
        %{
          location_id: location_a.id,
          title: "#{prefix} Vague issue B",
          description: issue_desc_vague,
          normalized_description: Text.normalize_for_dedupe(issue_desc_vague),
          status: :new
        },
        tenant: tenant,
        actor: nil
      )

    {:ok, issue_c} =
      Feedback.create_issue(
        %{
          location_id: location_b.id,
          title: "#{prefix} Vague issue C (other location)",
          description: issue_desc_vague,
          normalized_description: Text.normalize_for_dedupe(issue_desc_vague),
          status: :new
        },
        tenant: tenant,
        actor: nil
      )

    IO.puts("Created issue A: #{issue_a.id} (#{issue_a.title})")
    IO.puts("Created issue B: #{issue_b.id} (#{issue_b.title})")
    IO.puts("Created issue C: #{issue_c.id} (#{issue_c.title})")

    # Explicit example: same symptom at different locations should NOT get merged.
    {:ok, womens_cold_showers} =
      Feedback.create_issue(
        %{
          location_id: womens.id,
          title: "#{prefix} Women's locker room showers cold",
          description: issue_desc_vague,
          normalized_description: Text.normalize_for_dedupe(issue_desc_vague),
          status: :new
        },
        tenant: tenant,
        actor: nil
      )

    {:ok, mens_cold_showers} =
      Feedback.create_issue(
        %{
          location_id: mens.id,
          title: "#{prefix} Men's locker room showers cold",
          description: issue_desc_vague,
          normalized_description: Text.normalize_for_dedupe(issue_desc_vague),
          status: :new
        },
        tenant: tenant,
        actor: nil
      )

    IO.puts("Created women's showers issue: #{womens_cold_showers.id}")
    IO.puts("Created men's showers issue: #{mens_cold_showers.id}")

    # Seed "past reports" on each issue (these are what we now include in candidate payloads).
    create_reports_for_issue!(tenant, location_a, issue_a.id, [
      "#{marker_a} showers are ice cold; no hot water at all",
      "#{marker_a} thermostatic mixing valve seems broken; water never warms up",
      "#{marker_a} scald guard stuck; shower temperature is freezing",
      "#{marker_a} hot water out in men's showers after 7pm",
      "#{marker_a} shower temp fluctuates wildly; mostly cold"
    ])

    create_reports_for_issue!(tenant, location_a, issue_b.id, [
      "#{marker_b} guest wifi SSID disappears frequently",
      "#{marker_b} CTL_GUEST not visible; cannot connect",
      "#{marker_b} wifi keeps dropping every few minutes",
      "#{marker_b} lobby wifi is down again",
      "#{marker_b} captive portal fails to load"
    ])

    create_reports_for_issue!(tenant, location_b, issue_c.id, [
      "#{marker_c} soap dispensers are empty in the restroom",
      "#{marker_c} no soap in bathroom; dispenser broken",
      "#{marker_c} restroom soap is out again"
    ])

    create_reports_for_issue!(tenant, womens, womens_cold_showers.id, [
      "#{marker_w} showers are cold again",
      "#{marker_w} no hot water in women's locker room showers",
      "#{marker_w} women's showers freezing"
    ])

    create_reports_for_issue!(tenant, mens, mens_cold_showers.id, [
      "#{marker_m} showers are cold again",
      "#{marker_m} no hot water in men's locker room showers",
      "#{marker_m} men's showers freezing"
    ])

    IO.puts("Seeded past reports on issue A/B/C + locker room example")

    # Verify our candidate payload builder actually includes the past reports for these issues.
    candidates = list_candidates_like_worker!(tenant)
    payload = AIContext.candidate_payloads(tenant, candidates)

    assert_payload_has_marker!(payload, issue_a.id, marker_a)
    assert_payload_has_marker!(payload, issue_b.id, marker_b)
    assert_payload_has_marker!(payload, issue_c.id, marker_c)
    assert_payload_has_marker!(payload, womens_cold_showers.id, marker_w)
    assert_payload_has_marker!(payload, mens_cold_showers.id, marker_m)

    IO.puts("OK: candidate payload includes recent reports for issue A/B/C")

    # Now create a bunch of NEW incoming reports (issue_id=nil) and ensure they all get grouped
    # onto the expected issue.
    incoming_a_bodies =
      for i <- 1..6 do
        "#{marker_a} new complaint #{i}: showers are cold again"
      end

    incoming_b_bodies =
      for i <- 1..4 do
        "#{marker_b} new complaint #{i}: CTL_GUEST wifi not working"
      end

    incoming_c_bodies =
      for i <- 1..3 do
        "#{marker_c} new complaint #{i}: soap is missing"
      end

    womens_incoming_bodies =
      for i <- 1..3 do
        # Intentionally similar to men's, only the location differs.
        "#{marker_w} showers are cold again (women's) #{i}"
      end

    mens_incoming_bodies =
      for i <- 1..3 do
        "#{marker_m} showers are cold again (men's) #{i}"
      end

    incoming_a_ids =
      Enum.map(incoming_a_bodies, fn body ->
        report = create_incoming_report!(tenant, location_a, body)
        resolve_report!(tenant, report.id)
        report.id
      end)

    incoming_b_ids =
      Enum.map(incoming_b_bodies, fn body ->
        report = create_incoming_report!(tenant, location_a, body)
        resolve_report!(tenant, report.id)
        report.id
      end)

    incoming_c_ids =
      Enum.map(incoming_c_bodies, fn body ->
        report = create_incoming_report!(tenant, location_b, body)
        resolve_report!(tenant, report.id)
        report.id
      end)

    womens_incoming_ids =
      Enum.map(womens_incoming_bodies, fn body ->
        report = create_incoming_report!(tenant, womens, body)
        resolve_report!(tenant, report.id)
        report.id
      end)

    mens_incoming_ids =
      Enum.map(mens_incoming_bodies, fn body ->
        report = create_incoming_report!(tenant, mens, body)
        resolve_report!(tenant, report.id)
        report.id
      end)

    expected_a = to_string(issue_a.id)
    expected_b = to_string(issue_b.id)
    expected_c = to_string(issue_c.id)
    expected_w = to_string(womens_cold_showers.id)
    expected_m = to_string(mens_cold_showers.id)

    failures =
      []
      |> assert_reports_grouped_to_issue(tenant, incoming_a_ids, expected_a, "group A")
      |> assert_reports_grouped_to_issue(tenant, incoming_b_ids, expected_b, "group B")
      |> assert_reports_grouped_to_issue(tenant, incoming_c_ids, expected_c, "group C (other location)")
      |> assert_reports_grouped_to_issue(tenant, womens_incoming_ids, expected_w, "women's locker room")
      |> assert_reports_grouped_to_issue(tenant, mens_incoming_ids, expected_m, "men's locker room")

    # Front desk scenario: report location is generic, but text should map to the correct locker room issue.
    front_desk_reports = [
      {"front desk -> women's", "#{marker_w} Guest at front desk: women's locker room showers are cold"},
      {"front desk -> men's", "#{marker_m} Guest at front desk: men's locker room showers are cold"}
    ]

    failures =
      Enum.reduce(front_desk_reports, failures, fn {label, body}, acc ->
        report = create_incoming_report!(tenant, front_desk, body)
        resolve_report!(tenant, report.id)

        expected =
          case label do
            "front desk -> women's" -> expected_w
            "front desk -> men's" -> expected_m
          end

        assert_reports_grouped_to_issue(acc, tenant, [report.id], expected, label)
      end)

    if failures == [] do
      IO.puts("\nOK: all incoming reports were grouped as expected.")
    else
      IO.puts("\nFAILURES:")
      Enum.each(failures, &IO.puts("* " <> &1))
      raise "AI grouping smoke test failed (#{length(failures)} mismatches)"
    end
  end

  defp get_or_create_location!(tenant, name, full_path) do
    case Feedback.list_locations(tenant: tenant, query: [filter: [full_path: full_path], limit: 1]) do
      {:ok, [loc | _]} ->
        loc

      _ ->
        {:ok, loc} =
          Feedback.create_location(
            %{
              name: name,
              full_path: full_path
            },
            tenant: tenant,
            actor: nil
          )

        loc
    end
  end

  defp create_reports_for_issue!(tenant, location, issue_id, bodies) when is_list(bodies) do
    Enum.each(bodies, fn body ->
      {:ok, _report} =
        Feedback.create_report(
          %{
            body: body,
            source: :manual,
            # Provide location_id for clarity; the report change will force it to match the issue.
            location_id: location.id,
            issue_id: issue_id,
            consent: false
          },
          tenant: tenant,
          actor: nil
        )
    end)
  end

  defp create_incoming_report!(tenant, location, body) do
    {:ok, report} =
      Feedback.create_report(
        %{
          body: body,
          source: :qr,
          location_id: location.id,
          reporter_name: "AI Smoke",
          consent: false
        },
        tenant: tenant,
        actor: nil
      )

    if not is_nil(report.issue_id) do
      raise "Expected incoming report to start unassigned, but got issue_id=#{inspect(report.issue_id)}"
    end

    report
  end

  defp resolve_report!(tenant, report_id) do
    job =
      struct(Oban.Job, %{
        args: %{"tenant" => tenant, "report_id" => report_id},
        attempt: 1,
        max_attempts: 5
      })

    _ = ResolveReportIssueWorker.perform(job)
  end

  defp list_candidates_like_worker!(tenant) do
    query =
      CloseTheLoop.Feedback.Issue
      |> Ash.Query.for_read(:non_duplicates, %{})
      |> Ash.Query.filter(expr(status != :fixed))
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.Query.limit(25)
      |> Ash.Query.load([:reporter_count, location: [:name, :full_path]])

    case Ash.read(query, tenant: tenant) do
      {:ok, issues} -> issues
      other -> raise "Failed to list candidate issues: #{inspect(other)}"
    end
  end

  defp assert_payload_has_marker!(payload, issue_id, marker) when is_list(payload) do
    issue_id = to_string(issue_id)

    entry =
      Enum.find(payload, fn e ->
        (e[:id] || e["id"]) |> to_string() == issue_id
      end)

    if is_nil(entry) do
      raise "Candidate payload did not include expected issue #{issue_id}"
    end

    reports = entry[:recent_reports] || entry["recent_reports"] || []

    if reports == [] do
      raise "Candidate payload issue #{issue_id} had no recent_reports"
    end

    joined =
      reports
      |> Enum.map(&(Map.get(&1, :body) || Map.get(&1, "body") || ""))
      |> Enum.join("\n")

    if not String.contains?(joined, marker) do
      raise "Candidate payload issue #{issue_id} recent_reports did not include marker #{inspect(marker)}"
    end
  end

  defp assert_reports_grouped_to_issue(failures, tenant, report_ids, expected_issue_id, label)
       when is_list(failures) and is_binary(tenant) and is_list(report_ids) and
              is_binary(expected_issue_id) and is_binary(label) do
    Enum.reduce(report_ids, failures, fn report_id, acc ->
      {:ok, report} =
        Feedback.get_report_by_id(report_id,
          tenant: tenant,
          load: [issue: [:title], location: [:name, :full_path]]
        )

      actual = report.issue_id && to_string(report.issue_id)

      if actual == expected_issue_id do
        acc
      else
        title = report.issue && report.issue.title

        [
          "#{label}: report #{report_id} expected issue #{expected_issue_id}, got #{inspect(actual)} (title=#{inspect(title)})"
          | acc
        ]
      end
    end)
  end
end

CloseTheLoop.Scripts.AIReportResolutionSmoke.run()
