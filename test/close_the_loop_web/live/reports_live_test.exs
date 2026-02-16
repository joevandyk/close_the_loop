defmodule CloseTheLoopWeb.ReportsLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [create_membership!: 3, insert_org!: 1, register_user!: 1, unique_email: 1]

  alias CloseTheLoop.Feedback.{Issue, Location, Report}

  test "business can move a report to a different issue", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner")

    org = insert_org!(tenant)
    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    {:ok, location_a} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, location_b} =
      Ash.create(Location, %{name: "Locker room", full_path: "Locker room"}, tenant: tenant)

    {:ok, issue_a} =
      Ash.create(
        Issue,
        %{
          location_id: location_a.id,
          title: "Cold shower",
          description: "Cold shower",
          normalized_description: "cold shower",
          status: :new
        },
        tenant: tenant
      )

    {:ok, issue_b} =
      Ash.create(
        Issue,
        %{
          location_id: location_b.id,
          title: "Broken faucet",
          description: "Broken faucet",
          normalized_description: "broken faucet",
          status: :new
        },
        tenant: tenant
      )

    {:ok, report} =
      Ash.create(
        Report,
        %{
          location_id: location_a.id,
          issue_id: issue_a.id,
          body: "This is actually about the faucet",
          normalized_body: "this is actually about the faucet",
          source: :qr,
          reporter_phone: nil,
          consent: false
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/reports/#{report.id}")
    assert has_element?(view, "#report-move-modal[data-open=\"false\"]")
    assert has_element?(view, "#report-open-move-modal")

    view |> element("#report-open-move-modal") |> render_click()
    assert has_element?(view, "#report-move-modal[data-open=\"true\"]")
    assert has_element?(view, "#report-move-form")

    view
    |> form("#report-move-form", move: %{issue_id: issue_b.id})
    |> render_submit()

    assert render(view) =~ "Broken faucet"
    assert render(view) =~ "Locker room"
    assert has_element?(view, "#report-move-modal[data-open=\"false\"]")

    {:ok, _issue_view, issue_html} = live(conn, ~p"/app/#{org.id}/issues/#{issue_b.id}")
    assert issue_html =~ "This is actually about the faucet"

    {:ok, updated_report} = Ash.get(Report, report.id, tenant: tenant)
    assert updated_report.issue_id == issue_b.id
    assert updated_report.location_id == location_b.id
  end

  test "business can create a manual report (AI assignment pending)", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner")

    org = insert_org!(tenant)
    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/reports/new?location_id=#{location.id}")

    body = "Front desk: cold water in showers #{System.unique_integer([:positive])}"

    view
    |> form("#manual-report-form",
      manual: %{
        location_id: location.id,
        body: body,
        issue_id: "",
        reporter_name: "",
        reporter_email: "",
        reporter_phone: "",
        consent: "false"
      }
    )
    |> render_submit()

    {path, _flash} = assert_redirect(view)
    assert path =~ ~r|/app/#{org.id}/reports/|

    report_id = path |> String.split("/reports/") |> List.last()
    {:ok, report} = Ash.get(Report, report_id, tenant: tenant)

    assert report.location_id == location.id
    assert report.source == :manual
    assert report.body == body
    assert report.ai_resolution_status == :pending
    assert is_nil(report.issue_id)

    {:ok, reports} = Ash.read(Report, tenant: tenant)
    assert Enum.any?(reports, fn r -> r.source == :manual end)
  end

  test "business can create a manual report assigned to an existing issue", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner")

    org = insert_org!(tenant)
    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, issue} =
      Ash.create(
        Issue,
        %{
          location_id: location.id,
          title: "Cold shower",
          description: "Cold shower",
          normalized_description: "cold shower",
          status: :new
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/reports/new?location_id=#{location.id}")

    view
    |> form("#manual-report-form",
      manual: %{
        location_id: location.id,
        issue_id: issue.id,
        body: "Front desk says it's still cold",
        reporter_name: "",
        reporter_email: "",
        reporter_phone: "",
        consent: "false"
      }
    )
    |> render_submit()

    {:ok, reports} = Ash.read(Report, tenant: tenant)
    assert Enum.any?(reports, fn r -> r.source == :manual and r.issue_id == issue.id end)
  end

  test "new report issue picker populates after selecting a location", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner-issue-picker"))
    _membership = create_membership!(user, org.id, :owner)

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, _issue} =
      Ash.create(
        Issue,
        %{
          location_id: location.id,
          title: "Cold shower",
          description: "Cold shower",
          normalized_description: "cold shower",
          status: :new
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/reports/new")

    assert has_element?(view, "#manual-issue-none-wrapper")
    refute has_element?(view, "#manual-issue-none-wrapper[data-searchable]")

    view
    |> form("#manual-report-form",
      manual: %{
        location_id: location.id
      }
    )
    |> render_change()

    assert has_element?(view, "#manual-issue-#{location.id}-wrapper[data-searchable]")
    assert render(view) =~ "Cold shower"
  end
end
