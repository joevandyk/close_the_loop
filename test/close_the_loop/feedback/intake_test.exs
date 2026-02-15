defmodule CloseTheLoop.Feedback.IntakeTest do
  use CloseTheLoop.DataCase, async: true

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Feedback.{Intake, Issue, Location, Report}

  test "dedupes identical reports at same location" do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "Gym / Showers", full_path: "Gym → Men’s showers"},
        tenant: tenant
      )

    {:ok, %{issue: issue1}} =
      Intake.submit_report(tenant, location.id, %{
        body: "Cold water in the back-left stall",
        source: :qr,
        consent: false
      })

    {:ok, %{issue: issue2}} =
      Intake.submit_report(tenant, location.id, %{
        body: "Cold water in the back-left stall",
        source: :sms,
        reporter_phone: "+15555550100",
        consent: true
      })

    assert issue1.id == issue2.id

    {:ok, issue} = Ash.get(Issue, issue1.id, load: [:reporter_count], tenant: tenant)
    assert issue.reporter_count == 2
  end

  test "rejects invalid phone numbers when provided" do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "Gym", full_path: "Gym"}, tenant: tenant)

    assert {:error, msg} =
             Intake.submit_report(tenant, location.id, %{
               body: "Cold water",
               source: :qr,
               reporter_phone: "555-555-0100",
               consent: true
             })

    assert is_binary(msg)

    # Ensure we didn't store a report with that invalid phone.
    query =
      Report
      |> Ash.Query.filter(expr(body == "Cold water"))

    {:ok, reports} = Ash.read(query, tenant: tenant)
    assert reports == []
  end
end
