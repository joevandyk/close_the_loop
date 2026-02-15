defmodule CloseTheLoopWeb.ReportsLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Feedback.{Issue, Location, Report}

  test "business can move a report to a different issue", %{conn: conn} do
    tenant = "public"

    # Avoid triggering `manage_tenant` in tests (it would rerun tenant migrations).
    org_id = Ash.UUID.generate()
    org_id_bin = Ecto.UUID.dump!(org_id)
    now = DateTime.utc_now()

    {1, _} =
      CloseTheLoop.Repo.insert_all("organizations", [
        %{
          id: org_id_bin,
          name: "Test Org",
          tenant_schema: tenant,
          inserted_at: now,
          updated_at: now
        }
      ])

    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "owner@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        },
        action: :register_with_password,
        context: %{private: %{ash_authentication?: true}}
      )

    {:ok, user} =
      Ash.update(user, %{organization_id: org_id, role: :owner},
        action: :set_organization,
        actor: user
      )

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    {:ok, issue_a} =
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

    {:ok, issue_b} =
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

    {:ok, report} =
      Ash.create(
        Report,
        %{
          location_id: location.id,
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

    {:ok, view, _html} = live(conn, ~p"/app/reports/#{report.id}")
    assert has_element?(view, "#report-move-form")

    view
    |> form("#report-move-form", move: %{issue_id: issue_b.id})
    |> render_submit()

    assert render(view) =~ "Broken faucet"

    {:ok, _issue_view, issue_html} = live(conn, ~p"/app/issues/#{issue_b.id}")
    assert issue_html =~ "This is actually about the faucet"
  end

  test "business can create a manual report (auto issue)", %{conn: conn} do
    tenant = "public"

    # Avoid triggering `manage_tenant` in tests (it would rerun tenant migrations).
    org_id = Ash.UUID.generate()
    org_id_bin = Ecto.UUID.dump!(org_id)
    now = DateTime.utc_now()

    {1, _} =
      CloseTheLoop.Repo.insert_all("organizations", [
        %{
          id: org_id_bin,
          name: "Test Org",
          tenant_schema: tenant,
          inserted_at: now,
          updated_at: now
        }
      ])

    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "owner2@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        },
        action: :register_with_password,
        context: %{private: %{ash_authentication?: true}}
      )

    {:ok, user} =
      Ash.update(user, %{organization_id: org_id, role: :owner},
        action: :set_organization,
        actor: user
      )

    {:ok, location} =
      Ash.create(Location, %{name: "General", full_path: "General"}, tenant: tenant)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/reports/new?location_id=#{location.id}")

    body = "Front desk: cold water in showers"

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

    {:ok, issues} = Ash.read(Issue, tenant: tenant)
    issue = Enum.find(issues, fn i -> i.description == body end)
    assert issue

    assert_redirect(view, ~p"/app/issues/#{issue.id}")

    {:ok, reports} = Ash.read(Report, tenant: tenant)
    assert Enum.any?(reports, fn r -> r.source == :manual end)
  end

  test "business can create a manual report assigned to an existing issue", %{conn: conn} do
    tenant = "public"

    # Avoid triggering `manage_tenant` in tests (it would rerun tenant migrations).
    org_id = Ash.UUID.generate()
    org_id_bin = Ecto.UUID.dump!(org_id)
    now = DateTime.utc_now()

    {1, _} =
      CloseTheLoop.Repo.insert_all("organizations", [
        %{
          id: org_id_bin,
          name: "Test Org",
          tenant_schema: tenant,
          inserted_at: now,
          updated_at: now
        }
      ])

    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "owner3@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        },
        action: :register_with_password,
        context: %{private: %{ash_authentication?: true}}
      )

    {:ok, user} =
      Ash.update(user, %{organization_id: org_id, role: :owner},
        action: :set_organization,
        actor: user
      )

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

    {:ok, view, _html} = live(conn, ~p"/app/reports/new?location_id=#{location.id}")

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
end
