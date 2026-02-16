defmodule CloseTheLoopWeb.LocationsLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [create_membership!: 3, insert_org!: 1, register_user!: 1, unique_email: 1]

  alias CloseTheLoop.Feedback.Location

  test "locations create/edit uses a modal flow", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner-locations"))
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/locations")

    assert has_element?(view, "#location-modal[data-open=\"false\"]")

    view |> element("#locations-open-new") |> render_click()
    assert has_element?(view, "#location-modal[data-open=\"true\"]")
    assert has_element?(view, "#location-modal-form")

    view
    |> form("#location-modal-form",
      location: %{
        name: "Downtown",
        full_path: "Building A / Floor 2"
      }
    )
    |> render_submit()

    html = render(view)
    assert html =~ "Building A / Floor 2"
    assert has_element?(view, "#location-modal[data-open=\"false\"]")

    {:ok, locations} = Ash.read(Location, tenant: tenant)
    created = Enum.find(locations, fn l -> l.name == "Downtown" end)
    assert created

    view |> element("#locations-open-edit-#{created.id}") |> render_click()
    assert has_element?(view, "#location-modal[data-open=\"true\"]")
    assert has_element?(view, "#location-modal-name[value=\"Downtown\"]")

    view
    |> form("#location-modal-form",
      location: %{
        name: "Uptown",
        full_path: ""
      }
    )
    |> render_submit()

    html = render(view)
    assert html =~ "Uptown"
    assert has_element?(view, "#location-modal[data-open=\"false\"]")

    {:ok, updated} = Ash.get(Location, created.id, tenant: tenant)
    assert updated.name == "Uptown"
  end

  test "locations modal can be cancelled", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)
    user = register_user!(unique_email("owner-locations-cancel"))
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/locations")

    view |> element("#locations-open-new") |> render_click()
    assert has_element?(view, "#location-modal[data-open=\"true\"]")

    view |> element("#location-modal-cancel") |> render_click()
    assert has_element?(view, "#location-modal[data-open=\"false\"]")
  end
end
