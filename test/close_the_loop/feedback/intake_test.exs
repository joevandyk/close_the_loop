defmodule CloseTheLoop.Feedback.ReportIntakeTest do
  use CloseTheLoop.DataCase, async: true

  import Ash.Expr
  require Ash.Query

  alias CloseTheLoop.Feedback
  alias CloseTheLoop.Feedback.{Issue, Location, Report}

  test "does not dedupe identical report bodies automatically" do
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

    assert report1.issue_id != report2.issue_id

    {:ok, issue1} = Ash.get(Issue, report1.issue_id, load: [:reporter_count], tenant: tenant)
    {:ok, issue2} = Ash.get(Issue, report2.issue_id, load: [:reporter_count], tenant: tenant)

    assert issue1.reporter_count == 1
    assert issue2.reporter_count == 1
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
