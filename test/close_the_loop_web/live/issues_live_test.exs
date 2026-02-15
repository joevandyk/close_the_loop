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

  test "authenticated user can add internal comments to an issue", %{conn: conn} do
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

    {:ok, view, _html} = live(conn, ~p"/app/issues/#{issue.id}")
    assert has_element?(view, "#issue-internal-comment-form")

    view
    |> form("#issue-internal-comment-form",
      comment: %{body: "Called maintenance; plumber Tuesday."}
    )
    |> render_submit()

    assert render(view) =~ "Called maintenance; plumber Tuesday."
  end

  test "dangling org_id does not crash issues page", %{conn: conn} do
    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "dangling@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        },
        action: :register_with_password,
        context: %{private: %{ash_authentication?: true}}
      )

    # Point at a non-existent org (this can happen in dev if org rows are removed).
    org_id = Ash.UUID.generate()

    {:ok, user} =
      Ash.update(user, %{organization_id: org_id, role: :owner},
        action: :set_organization,
        actor: user
      )

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, _view, html} = live(conn, ~p"/app/issues")
    assert html =~ "Inbox"
    assert html =~ "No issues yet."
  end

  test "owner can edit an issue title and description", %{conn: conn} do
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

    {:ok, view, _html} = live(conn, ~p"/app/issues/#{issue.id}")
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
          email: "staff@example.com",
          password: "password1234",
          password_confirmation: "password1234"
        },
        action: :register_with_password,
        context: %{private: %{ash_authentication?: true}}
      )

    {:ok, user} =
      Ash.update(user, %{organization_id: org_id, role: :staff},
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

    {:ok, view, _html} = live(conn, ~p"/app/issues/#{issue.id}")
    refute has_element?(view, "#issue-edit-details-toggle")
  end
end
