defmodule CloseTheLoopWeb.IssuesLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Feedback.{Issue, Location}

  test "authenticated user with org can view issues inbox", %{conn: conn} do
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

    {:ok, _view, html} = live(conn, ~p"/app/issues")
    assert html =~ "Inbox"
    assert html =~ "Cold shower"
  end
end
