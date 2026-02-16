defmodule CloseTheLoop.Accounts.OrganizationInvitation.Changes.SendInvitationEmail do
  @moduledoc false

  use Ash.Resource.Change

  require Logger

  alias CloseTheLoop.Accounts.OrganizationInvitation
  alias CloseTheLoop.Accounts.OrganizationInvitation.Senders.SendInvitationEmail
  alias CloseTheLoop.Tenants
  alias CloseTheLoop.Tenants.Organization

  @impl true
  def change(changeset, _opts, context) do
    Ash.Changeset.after_transaction(changeset, fn _changeset, result ->
      case result do
        {:ok, %OrganizationInvitation{} = invite} ->
          maybe_send(invite, context)
          result

        _ ->
          result
      end
    end)
  end

  defp maybe_send(%OrganizationInvitation{} = invite, context) do
    with actor when not is_nil(actor) <- context.actor,
         {:ok, %Organization{} = org} <- Tenants.get_organization_by_id(invite.organization_id) do
      SendInvitationEmail.send(to_string(invite.email), invite.token,
        organization: org,
        inviter: actor
      )
    else
      _ ->
        # The invitation is already created; failing email should not crash the request.
        Logger.warning("Failed to send org invitation email", invite_id: invite.id)
        :ok
    end
  rescue
    exception ->
      Logger.warning("Failed to send org invitation email: #{Exception.message(exception)}",
        invite_id: invite.id
      )

      :ok
  end
end
