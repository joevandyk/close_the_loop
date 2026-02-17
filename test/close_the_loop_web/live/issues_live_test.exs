defmodule CloseTheLoopWeb.IssuesLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [
      create_membership!: 3,
      insert_org!: 1,
      promote_to_admin!: 1,
      register_user!: 1,
      unique_email: 1
    ]

  alias CloseTheLoop.Feedback.{Issue, Location, Report}

  test "authenticated user with org can view issues inbox", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner")

    org = insert_org!(tenant)
    user = register_user!(email)
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

    {:ok, _view, html} = live(conn, ~p"/app/#{org.id}/issues")
    assert html =~ "Issues"
    assert html =~ "Cold shower"
  end

  test "admin can view any org issues inbox without membership", %{conn: conn} do
    tenant = "public"
    email = unique_email("admin")

    org = insert_org!(tenant)

    user =
      email
      |> register_user!()
      |> promote_to_admin!()

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, _issue} =
      Ash.create(
        Issue,
        %{
          location_id: location.id,
          title: "Lights out",
          description: "Hallway lights are out",
          normalized_description: "hallway lights are out",
          status: :new
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, _view, html} = live(conn, ~p"/app/#{org.id}/issues")
    assert html =~ "Issues"
    assert html =~ "Lights out"
  end

  test "authenticated user can add internal comments to an issue", %{conn: conn} do
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

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")
    assert has_element?(view, "#issue-open-add-update")
    refute has_element?(view, "#issue-internal-comment-form")
    assert has_element?(view, "#issue-activity")

    view |> element("#issue-open-add-update") |> render_click()
    assert has_element?(view, "#issue-add-update-form")

    view
    |> form("#issue-add-update-form",
      issue_update: %{comment_body: "Called maintenance; plumber Tuesday."}
    )
    |> render_submit()

    assert render(view) =~ "Called maintenance; plumber Tuesday."
  end

  test "issue send sms uses a modal and requires confirmation", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner-sms")

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

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")
    assert has_element?(view, "#issue-open-send-sms")
    refute has_element?(view, "#issue-update-form")

    view |> element("#issue-open-send-sms") |> render_click()
    assert has_element?(view, "#issue-send-sms-form")

    view
    |> form("#issue-send-sms-form", update: %{message: "Hello everyone"})
    |> render_submit()

    assert render(view) =~ "Please confirm before sending."
  end

  test "add report link goes to reporter intake page", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner-add-report")

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

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")
    assert has_element?(view, "#issue-open-add-report[href='/r/#{tenant}/#{location.id}']")
  end

  test "issue show report items link to report detail", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner-report-links")

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

    {:ok, report} =
      Ash.create(
        Report,
        %{
          location_id: location.id,
          issue_id: issue.id,
          body: "Front desk says it's still cold",
          normalized_body: "front desk says it's still cold",
          source: :manual,
          reporter_phone: nil,
          consent: false
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")

    assert has_element?(view, "#issue-report-link-#{report.id}")

    assert has_element?(
             view,
             "#issue-report-link-#{report.id}[href=\"/app/#{org.id}/reports/#{report.id}\"]"
           )
  end

  test "issue status changes show what changed in activity feed", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner-status-activity")

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

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")

    view
    |> element("#issue-open-add-update")
    |> render_click()

    view
    |> element("#issue-add-update-form button[phx-value-status='acknowledged']")
    |> render_click()

    view
    |> form("#issue-add-update-form", issue_update: %{comment_body: ""})
    |> render_submit()

    activity_html = view |> element("#issue-activity") |> render()
    assert activity_html =~ "Status changed"
    assert activity_html =~ "Status:"
    assert activity_html =~ "New"
    assert activity_html =~ "Acknowledged"
  end

  test "dangling org_id does not crash issues page", %{conn: conn} do
    email = unique_email("dangling")
    user = register_user!(email)

    # Point at a non-existent org. With org-in-URL and membership checks,
    # the app should safely redirect the signed-in user.
    org_id = Ash.UUID.generate()

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    assert {:error, {:redirect, %{to: "/app/onboarding"}}} = live(conn, ~p"/app/#{org_id}/issues")
  end

  test "owner can edit an issue title and description", %{conn: conn} do
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

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")
    assert has_element?(view, "#issue-edit-details-toggle")

    view |> element("#issue-edit-details-toggle") |> render_click()
    assert has_element?(view, "#issue-edit-details-form")

    view
    |> form("#issue-edit-details-form",
      issue: %{
        title: "Hot shower",
        description: "Maintenance replaced the unit."
      }
    )
    |> render_submit()

    html = render(view)
    assert html =~ "Hot shower"
    assert html =~ "Maintenance replaced the unit."
  end

  test "staff cannot see issue edit controls", %{conn: conn} do
    tenant = "public"
    email = unique_email("staff")

    org = insert_org!(tenant)
    user = register_user!(email)
    _membership = create_membership!(user, org.id, :staff)

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

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/issues/#{issue.id}")
    refute has_element?(view, "#issue-edit-details-toggle")
  end

  test "issues inbox supports status filter via query params", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner-status-filter"))
    _membership = create_membership!(user, org.id, :owner)

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, _new_issue} =
      Ash.create(
        Issue,
        %{
          location_id: location.id,
          title: "New issue",
          description: "New issue",
          normalized_description: "new issue",
          status: :new
        },
        tenant: tenant
      )

    {:ok, _in_progress_issue} =
      Ash.create(
        Issue,
        %{
          location_id: location.id,
          title: "In progress issue",
          description: "In progress issue",
          normalized_description: "in progress issue",
          status: :in_progress
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, _view, html} = live(conn, ~p"/app/#{org.id}/issues?status=in_progress")
    assert html =~ "In progress issue"
    refute html =~ "New issue"
  end

  test "issues inbox supports search via q query param", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner-search"))
    _membership = create_membership!(user, org.id, :owner)

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, _a} =
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

    {:ok, _b} =
      Ash.create(
        Issue,
        %{
          location_id: location.id,
          title: "Broken faucet",
          description: "Broken faucet",
          normalized_description: "broken faucet",
          status: :new
        },
        tenant: tenant
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    # Case-insensitive search
    {:ok, _view, html} = live(conn, ~p"/app/#{org.id}/issues?q=FAUCET")
    assert html =~ "Broken faucet"
    refute html =~ "Cold shower"
  end
end
