defmodule CloseTheLoop.Feedback.ReportIntakeTest do
  use CloseTheLoop.DataCase, async: true

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.{Location, Report}

  test "creates reports without an issue when issue is omitted" do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "Gym / Showers", full_path: "Gym -> Mens showers"},
        tenant: tenant
      )

    body = "Cold water in the back-left stall #{System.unique_integer([:positive])}"

    {:ok, report1} =
      Feedback.create_report(
        %{location_id: location.id, body: body, source: :qr},
        tenant: tenant,
        authorize?: false,
        actor: nil
      )

    {:ok, report2} =
      Feedback.create_report(
        %{
          location_id: location.id,
          body: body,
          source: :sms,
          reporter_phone: "+15555550100",
          consent: true
        },
        tenant: tenant,
        authorize?: false,
        actor: nil
      )

    # Issue assignment is done asynchronously (OpenAI-backed). Intake saves the reports
    # immediately and queues background resolution.
    assert is_nil(report1.issue_id)
    assert is_nil(report2.issue_id)

    assert report1.ai_resolution_status == :pending
    assert report2.ai_resolution_status == :pending
  end

  test "rejects invalid phone numbers when provided" do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "Gym", full_path: "Gym"}, tenant: tenant)

    body = "Cold water #{System.unique_integer([:positive])}"

    assert {:error, _} =
             Feedback.create_report(
               %{
                 location_id: location.id,
                 body: body,
                 source: :qr,
                 reporter_phone: "555-555-010",
                 consent: true
               },
               tenant: tenant,
               authorize?: false,
               actor: nil
             )

    # Ensure we didn't store a report with that invalid phone.
    query =
      Report
      |> Ash.Query.filter(expr(body == ^body))

    {:ok, reports} = Ash.read(query, tenant: tenant)
    assert reports == []
  end

  test "stores optional reporter name/email when provided" do
    tenant = "public"

    {:ok, location} =
      Ash.create(Location, %{name: "Gym", full_path: "Gym"}, tenant: tenant)

    body = "The sauna is too cold #{System.unique_integer([:positive])}"

    {:ok, report} =
      Feedback.create_report(
        %{
          location_id: location.id,
          body: body,
          source: :qr,
          reporter_name: "  Alex  ",
          reporter_email: " alex@example.com ",
          consent: false
        },
        tenant: tenant,
        authorize?: false,
        actor: nil
      )

    assert report.reporter_name == "Alex"
    assert report.reporter_email == "alex@example.com"
  end
end
