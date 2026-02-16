defmodule CloseTheLoopWeb.OrganizationInvitationControllerTest do
  use CloseTheLoopWeb.ConnCase, async: true

  import CloseTheLoop.TestHelpers,
    only: [create_membership!: 3, insert_org!: 1, register_user!: 1, unique_email: 1]

  alias CloseTheLoop.Accounts

  test "GET /invites/:token redirects to sign-in and sets return_to when not signed in", %{
    conn: conn
  } do
    tenant = "public"
    org = insert_org!(tenant)

    owner = register_user!(unique_email("invite-owner"))
    _membership = create_membership!(owner, org.id, :owner)

    invited_email = unique_email("invitee")

    {:ok, invite} =
      Accounts.invite_user_to_organization(
        %{
          organization_id: org.id,
          email: invited_email,
          role: :staff
        },
        actor: owner
      )

    conn =
      conn
      |> init_test_session(%{})
      |> get(~p"/invites/#{invite.token}")

    assert redirected_to(conn) == ~p"/register"
    assert get_session(conn, :return_to) == "/invites/#{invite.token}"
  end

  test "invite can be accepted by a user with a different email address", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)

    owner = register_user!(unique_email("invite-owner-diff"))
    _membership = create_membership!(owner, org.id, :owner)

    invited_email = unique_email("invitee-diff")

    {:ok, invite} =
      Accounts.invite_user_to_organization(
        %{
          organization_id: org.id,
          email: invited_email,
          role: :staff
        },
        actor: owner
      )

    other_user = register_user!(unique_email("someone-else"))

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(other_user)

    conn = get(conn, ~p"/invites/#{invite.token}")
    assert html_response(conn, 200) =~ "Accept invitation"

    conn = post(conn, ~p"/invites/#{invite.token}/accept")
    assert redirected_to(conn) == "/app/#{org.id}/issues"

    assert {:ok, membership} =
             Accounts.get_user_organization_by_user_org(other_user.id, org.id, authorize?: false)

    assert membership.role == :staff
  end

  test "invite can be accepted by the invited email and creates membership", %{conn: conn} do
    tenant = "public"
    org = insert_org!(tenant)

    owner = register_user!(unique_email("invite-owner-accept"))
    _membership = create_membership!(owner, org.id, :owner)

    invited_email = unique_email("invitee-accept")

    {:ok, invite} =
      Accounts.invite_user_to_organization(
        %{
          organization_id: org.id,
          email: invited_email,
          role: :staff
        },
        actor: owner
      )

    invitee = register_user!(invited_email)

    conn =
      conn
      |> init_test_session(%{})
      |> AshAuthentication.Plug.Helpers.store_in_session(invitee)

    conn = get(conn, ~p"/invites/#{invite.token}")
    assert html_response(conn, 200) =~ "Accept invitation"

    conn = post(conn, ~p"/invites/#{invite.token}/accept")
    assert redirected_to(conn) == "/app/#{org.id}/issues"

    assert {:ok, membership} =
             Accounts.get_user_organization_by_user_org(invitee.id, org.id, authorize?: false)

    assert membership.role == :staff
  end
end
