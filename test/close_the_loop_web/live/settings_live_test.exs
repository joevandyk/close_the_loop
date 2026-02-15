defmodule CloseTheLoopWeb.SettingsLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CloseTheLoop.Accounts.User

  defp create_org_row!(tenant) do
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

    org_id
  end

  test "user can update their name", %{conn: conn} do
    tenant = "public"
    org_id = create_org_row!(tenant)

    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "owner-name@example.com",
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

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/settings")
    assert has_element?(view, "#user-profile-form")

    view
    |> form("#user-profile-form", profile: %{name: "Jane Owner"})
    |> render_submit()

    assert render(view) =~ "Profile updated."
    assert render(view) =~ "Jane Owner"
  end

  test "user can change their email (with current password)", %{conn: conn} do
    tenant = "public"
    org_id = create_org_row!(tenant)

    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "owner-email-old@example.com",
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

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/settings")
    assert has_element?(view, "#user-email-form")

    view
    |> form("#user-email-form",
      email: %{email: "owner-email-new@example.com", current_password: "password1234"}
    )
    |> render_submit()

    assert render(view) =~ "Email updated."
    assert render(view) =~ "owner-email-new@example.com"

    user_id = Ecto.UUID.dump!(user.id)

    assert %{rows: [["owner-email-new@example.com"]]} =
             CloseTheLoop.Repo.query!("SELECT email FROM users WHERE id = $1", [user_id])
  end

  test "user can change their password (with current password)", %{conn: conn} do
    tenant = "public"
    org_id = create_org_row!(tenant)

    {:ok, user} =
      Ash.create(
        User,
        %{
          email: "owner-password@example.com",
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

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/settings")
    assert has_element?(view, "#user-password-form")

    view
    |> form("#user-password-form",
      password: %{
        current_password: "password1234",
        password: "newpassword1234",
        password_confirmation: "newpassword1234"
      }
    )
    |> render_submit()

    assert render(view) =~ "Password updated."

    user_id = Ecto.UUID.dump!(user.id)

    assert %{rows: [[hashed_password]]} =
             CloseTheLoop.Repo.query!("SELECT hashed_password FROM users WHERE id = $1", [user_id])

    refute Bcrypt.verify_pass("password1234", hashed_password)
    assert Bcrypt.verify_pass("newpassword1234", hashed_password)
  end
end
