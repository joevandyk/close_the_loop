defmodule CloseTheLoopWeb.SettingsLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [create_membership!: 3, insert_org!: 1, register_user!: 1, unique_email: 1]

  test "user can update their name", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    email = unique_email("owner-name")

    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/account")
    assert has_element?(view, "#user-profile-form")

    view
    |> form("#user-profile-form", profile: %{name: "Jane Owner"})
    |> render_submit()

    assert render(view) =~ "Profile updated."
    assert render(view) =~ "Jane Owner"
  end

  test "change email with incorrect password shows error and does not update email", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    email_old = unique_email("owner-email-wrong-pw")
    email_new = unique_email("owner-email-changed")

    user = register_user!(email_old)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/account")
    assert has_element?(view, "#user-email-form")

    view
    |> form("#user-email-form",
      email: %{email: email_new, current_password: "wrongpassword"}
    )
    |> render_submit()

    refute render(view) =~ "Email updated."
    assert render(view) =~ "Current password is incorrect."
    refute render(view) =~ "(splode"

    user_id = Ecto.UUID.dump!(user.id)

    assert %{rows: [[^email_old]]} =
             CloseTheLoop.Repo.query!("SELECT email FROM users WHERE id = $1", [user_id])
  end

  test "user can change their email (with current password)", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    email_old = unique_email("owner-email-old")
    email_new = unique_email("owner-email-new")

    user = register_user!(email_old)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/account")
    assert has_element?(view, "#user-email-form")

    view
    |> form("#user-email-form",
      email: %{email: email_new, current_password: "password1234"}
    )
    |> render_submit()

    assert render(view) =~ "Email updated."
    assert render(view) =~ email_new

    user_id = Ecto.UUID.dump!(user.id)

    assert %{rows: [[^email_new]]} =
             CloseTheLoop.Repo.query!("SELECT email FROM users WHERE id = $1", [user_id])
  end

  test "change password with incorrect current password shows error and does not update", %{
    conn: conn
  } do
    tenant = "public"
    org = insert_org!(tenant)
    email = unique_email("owner-password-wrong")

    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/account")
    assert has_element?(view, "#user-password-form")

    view
    |> form("#user-password-form",
      password: %{
        current_password: "wrongpassword",
        password: "newpassword1234",
        password_confirmation: "newpassword1234"
      }
    )
    |> render_submit()

    refute render(view) =~ "Password updated."
    assert render(view) =~ "Current password is incorrect."
    refute render(view) =~ "(splode"

    user_id = Ecto.UUID.dump!(user.id)

    assert %{rows: [[hashed_password]]} =
             CloseTheLoop.Repo.query!("SELECT hashed_password FROM users WHERE id = $1", [user_id])

    assert Bcrypt.verify_pass("password1234", hashed_password)
  end

  test "user can change their password (with current password)", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    email = unique_email("owner-password")

    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/account")
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
