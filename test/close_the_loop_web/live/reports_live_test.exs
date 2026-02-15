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
end
