defmodule CloseTheLoopWeb.OrganizationInvitationController do
  use CloseTheLoopWeb, :controller

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Accounts.OrganizationInvitation
  alias CloseTheLoop.Tenants
  alias CloseTheLoop.Tenants.Organization

  def show(conn, %{"token" => token}) do
    case Accounts.get_organization_invitation_by_token(token, authorize?: false) do
      {:ok, %OrganizationInvitation{} = invite} ->
        conn = maybe_redirect_to_sign_in(conn, token)

        if conn.halted do
          conn
        else
          with {:ok, %Organization{} = org} <-
                 Tenants.get_organization_by_id(invite.organization_id) do
            {state, message} = invitation_state(invite, conn.assigns[:current_user])

            render(conn, :show,
              invite: invite,
              org: org,
              state: state,
              message: message
            )
          else
            _ ->
              conn
              |> put_flash(:error, "Organization not found.")
              |> redirect(to: ~p"/")
          end
        end

      _ ->
        conn
        |> put_flash(:error, "Invitation not found.")
        |> redirect(to: ~p"/")
    end
  end

  def accept(conn, %{"token" => token}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_session(:return_to, ~p"/invites/#{token}")
        |> redirect(to: ~p"/register")

      user ->
        with {:ok, %OrganizationInvitation{} = invite} <-
               Accounts.get_organization_invitation_by_token(token, authorize?: false),
             {:ok, %OrganizationInvitation{}} <-
               Accounts.accept_organization_invitation(invite, %{}, actor: user) do
          conn
          |> put_flash(:info, "You're in. Welcome!")
          |> redirect(to: ~p"/app/#{invite.organization_id}/issues")
        else
          {:error, err} ->
            conn
            |> put_flash(:error, error_message(err))
            |> redirect(to: ~p"/invites/#{token}")

          _ ->
            conn
            |> put_flash(:error, "Invitation not found.")
            |> redirect(to: ~p"/")
        end
    end
  end

  defp maybe_redirect_to_sign_in(%{halted: true} = conn, _token), do: conn

  defp maybe_redirect_to_sign_in(conn, token) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_session(:return_to, ~p"/invites/#{token}")
      |> redirect(to: ~p"/register")
      |> halt()
    end
  end

  defp invitation_state(%OrganizationInvitation{} = invite, _user) do
    cond do
      invite.revoked_at ->
        {:revoked, "This invitation has been revoked."}

      invite.accepted_at ->
        {:accepted, "This invitation has already been accepted."}

      expired?(invite) ->
        {:expired, "This invitation has expired."}

      true ->
        {:ok, nil}
    end
  end

  defp expired?(%OrganizationInvitation{expires_at: %DateTime{} = expires_at}) do
    DateTime.compare(expires_at, DateTime.utc_now()) != :gt
  end

  defp expired?(_), do: true

  defp error_message(%Ash.Error.Forbidden{errors: [%{message: message} | _]})
       when is_binary(message),
       do: message

  defp error_message(%Ash.Error.Invalid{errors: [%{message: message} | _]})
       when is_binary(message),
       do: message

  defp error_message(err) when Kernel.is_exception(err), do: Exception.message(err)
  defp error_message(_), do: "Something went wrong. Please try again."
end
