defmodule CloseTheLoopWeb.OnboardingLiveTest do
  use CloseTheLoopWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [
      create_membership!: 3,
      insert_org!: 1,
      register_user!: 1,
      unique_email: 1
    ]

  test "signed-in user with no org memberships is redirected to /app/onboarding", %{conn: conn} do
    user = register_user!(unique_email("no-org"))

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    assert {:error, {:live_redirect, %{to: "/app/onboarding"}}} = live(conn, ~p"/app")
  end

  test "getting started page renders checklist and inline location form", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner"))
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, _view, html} = live(conn, ~p"/app/#{org.id}/onboarding")
    assert html =~ "Getting started"
    assert html =~ "Create your first location"
    assert html =~ "getting-started-location-form"
    assert html =~ ~s|/app/#{org.id}/settings/locations|
  end

  test "creating a location on getting started page unlocks poster and reporter CTAs", %{
    conn: conn
  } do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner-loc"))
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/onboarding")

    view
    |> form("#getting-started-location-form",
      location: %{
        name: "Lobby",
        full_path: ""
      }
    )
    |> render_submit()

    html = render(view)
    assert html =~ "Lobby"
    assert html =~ "Open poster (PDF)"
    assert html =~ "Open reporter link"
    assert html =~ "/r/#{tenant}/"
    assert html =~ "/poster"
  end

  test "org creation from /app/onboarding redirects into org-scoped getting started", %{
    conn: conn
  } do
    user = register_user!(unique_email("onboarding-create"))

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/onboarding")

    view
    |> form("#onboarding-form", onboarding: %{org_name: "Acme Gym"})
    |> render_submit()

    {path, _flash} = assert_redirect(view)
    assert path =~ ~r|^/app/[^/]+/onboarding$|
  end
end
