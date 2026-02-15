defmodule CloseTheLoopWeb.IssueCategoriesLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CloseTheLoop.Accounts.User
  alias CloseTheLoop.Feedback.IssueCategory

  test "owner can deactivate and reactivate a category", %{conn: conn} do
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
          email: "owner-cats@example.com",
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

    {:ok, view, _html} = live(conn, ~p"/app/settings/issue-categories")

    {:ok, cats} = Ash.read(IssueCategory, tenant: tenant)
    cat = Enum.find(cats, fn c -> c.key == "plumbing" end) || hd(cats)

    # Deactivate
    assert has_element?(view, "#category-#{cat.id}", "Active")

    view
    |> element(~s|button[phx-click="toggle_active"][phx-value-id="#{cat.id}"]|)
    |> render_click()

    assert has_element?(view, "#category-#{cat.id}", "Inactive")

    # Reactivate
    view
    |> element(~s|button[phx-click="toggle_active"][phx-value-id="#{cat.id}"]|)
    |> render_click()

    assert has_element?(view, "#category-#{cat.id}", "Active")
  end

  test "owner can save AI settings", %{conn: conn} do
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
          email: "owner-ai-settings@example.com",
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

    {:ok, view, _html} = live(conn, ~p"/app/settings/issue-categories")
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
