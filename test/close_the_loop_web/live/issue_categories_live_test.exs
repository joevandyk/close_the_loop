defmodule CloseTheLoopWeb.IssueCategoriesLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [create_membership!: 3, insert_org!: 1, register_user!: 1, unique_email: 1]

  alias CloseTheLoop.Feedback.IssueCategory

  test "owner can deactivate and reactivate a category", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner-cats")

    org = insert_org!(tenant)
    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/issue-categories")

    {:ok, cats} = Ash.read(IssueCategory, tenant: tenant)
    cat = Enum.find(cats, fn c -> c.key == "plumbing" end) || hd(cats)

    # Deactivate
    assert has_element?(view, "#category-#{cat.id}", "Active")

    view
    |> element("#category-toggle-active-#{cat.id}")
    |> render_click()

    assert has_element?(view, "#category-#{cat.id}", "Inactive")

    # Reactivate
    view
    |> element("#category-toggle-active-#{cat.id}")
    |> render_click()

    assert has_element?(view, "#category-#{cat.id}", "Active")
  end

  test "owner can save AI settings", %{conn: conn} do
    tenant = "public"
    email = unique_email("owner-ai-settings")

    org = insert_org!(tenant)
    user = register_user!(email)
    _membership = create_membership!(user, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(user)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/issue-categories")
    assert has_element?(view, "#ai-settings-form")

    view
    |> form("#ai-settings-form",
      ai: %{
        business_context: "We run a gym with saunas and locker rooms.",
        categorization_instructions: "If it mentions shower water temp then plumbing."
      }
    )
    |> render_submit()

    html = render(view)
    assert html =~ "AI settings saved."
    assert html =~ "We run a gym with saunas and locker rooms."
    assert html =~ "If it mentions shower water temp then plumbing."
  end
end
