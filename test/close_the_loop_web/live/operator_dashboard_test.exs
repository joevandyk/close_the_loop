defmodule CloseTheLoopWeb.OperatorDashboardTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [insert_org!: 1, register_user!: 1, unique_email: 1, promote_to_admin!: 1]

  defp sign_in(conn, user) do
    conn
    |> init_test_session(%{})
    |> AshAuthentication.Plug.Helpers.store_in_session(user)
  end

  describe "admin access" do
    test "admin user can access /ops and sees the dashboard", %{conn: conn} do
      _org = insert_org!("public")
      email = unique_email("ops-admin")
      user = register_user!(email) |> promote_to_admin!()

      conn = sign_in(conn, user)
      {:ok, view, html} = live(conn, ~p"/ops")

      assert html =~ "Ops Dashboard"
      assert has_element?(view, "#ops-stats")
      assert has_element?(view, "#ops-organizations")
      assert has_element?(view, "#ops-users")
      assert has_element?(view, "#ops-invitations")
    end

    test "non-admin user is redirected away from /ops", %{conn: conn} do
      email = unique_email("ops-nonadmin")
      user = register_user!(email)

      conn = sign_in(conn, user)
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/ops")
      assert path == "/app"
    end

    test "unauthenticated user is redirected to sign-in", %{conn: conn} do
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/ops")
      assert path == "/sign-in"
    end
  end

  describe "dashboard content" do
    test "shows organization and user counts", %{conn: conn} do
      org = insert_org!("public")

      admin_email = unique_email("ops-admin-content")
      admin = register_user!(admin_email) |> promote_to_admin!()

      other_email = unique_email("ops-other-user")
      _other_user = register_user!(other_email)

      conn = sign_in(conn, admin)
      {:ok, _view, html} = live(conn, ~p"/ops")

      assert html =~ org.name
      assert html =~ admin_email
      assert html =~ other_email
    end
  end
end
