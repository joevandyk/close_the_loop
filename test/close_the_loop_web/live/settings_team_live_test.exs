defmodule CloseTheLoopWeb.SettingsTeamLiveTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CloseTheLoop.TestHelpers,
    only: [create_membership!: 3, insert_org!: 1, register_user!: 1, unique_email: 1]

  alias CloseTheLoop.Accounts

  test "owner can view team settings and send an invite", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)

    owner = register_user!(unique_email("team-owner"))
    _membership = create_membership!(owner, org.id, :owner)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(owner)

    {:ok, view, _html} = live(conn, ~p"/app/#{org.id}/settings/team")
    assert has_element?(view, "#org-invite-form")

    invited_email = unique_email("teammate")

    view
    |> form("#org-invite-form",
      invite: %{
        organization_id: org.id,
        email: invited_email,
        role: "staff"
      }
    )
    |> render_submit()

    assert render(view) =~ "Invitation sent."

    assert {:ok, invites} =
             Accounts.list_pending_organization_invitations(%{organization_id: org.id},
               actor: owner,
               authorize?: false
             )

    assert Enum.any?(invites, &(to_string(&1.email) == invited_email))
  end

  test "staff is redirected away from team settings", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)

    staff = register_user!(unique_email("team-staff"))
    _membership = create_membership!(staff, org.id, :staff)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(staff)

    assert {:error, {_kind, %{to: to}}} = live(conn, ~p"/app/#{org.id}/settings/team")
    assert to == "/app/#{org.id}/settings"
  end
end
