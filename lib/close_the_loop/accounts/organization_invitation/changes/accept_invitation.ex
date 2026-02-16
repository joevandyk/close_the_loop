defmodule CloseTheLoop.Accounts.OrganizationInvitation.Changes.AcceptInvitation do
  @moduledoc false

  use Ash.Resource.Change

  alias CloseTheLoop.Accounts
  alias CloseTheLoop.Accounts.OrganizationInvitation

  @impl true
  def change(changeset, _opts, context) do
    actor = context.actor

    changeset =
      Ash.Changeset.before_action(changeset, fn changeset ->
        Ash.Changeset.force_change_attribute(changeset, :accepted_at, DateTime.utc_now())
      end)

    Ash.Changeset.after_action(changeset, fn _changeset, %OrganizationInvitation{} = invite ->
      ensure_membership(actor, invite)
    end)
  end

  defp ensure_membership(nil, _invite), do: {:error, "You must be signed in to accept an invite."}

  defp ensure_membership(actor, %OrganizationInvitation{} = invite) do
    case Accounts.get_user_organization_by_user_org(actor.id, invite.organization_id,
           authorize?: false
         ) do
      {:ok, %{}} ->
        {:ok, invite}

      {:ok, nil} ->
        create_membership(actor, invite)

      {:error, _} ->
        create_membership(actor, invite)
    end
  end

  defp create_membership(actor, %OrganizationInvitation{} = invite) do
    Accounts.create_user_organization(
      %{
        user_id: actor.id,
        organization_id: invite.organization_id,
        role: invite.role
      },
      actor: actor
    )
    |> case do
      {:ok, _membership} -> {:ok, invite}
      {:error, err} -> {:error, err}
    end
  end
end
