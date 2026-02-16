defmodule CloseTheLoop.Accounts.OrganizationInvitation.Validations.InviterIsOwner do
  @moduledoc false

  use Ash.Resource.Validation

  alias CloseTheLoop.Accounts

  @impl true
  def init(opts), do: {:ok, opts}

  @impl true
  def validate(changeset, _opts, context) do
    actor = context.actor
    org_id = org_id_from_changeset(changeset)

    cond do
      is_nil(actor) ->
        {:error,
         Ash.Error.Forbidden.exception(message: "You must be signed in to invite people.")}

      is_nil(org_id) ->
        {:error,
         Ash.Error.Changes.InvalidChanges.exception(
           fields: [:organization_id],
           message: "Organization is required."
         )}

      true ->
        case Accounts.get_user_organization_by_user_org(actor.id, org_id, authorize?: false) do
          {:ok, %{role: :owner}} ->
            :ok

          _ ->
            {:error,
             Ash.Error.Forbidden.exception(
               message: "Only organization owners can invite or revoke invitations."
             )}
        end
    end
  end

  defp org_id_from_changeset(changeset) do
    Ash.Changeset.get_argument(changeset, :organization_id) ||
      Ash.Changeset.get_attribute(changeset, :organization_id) ||
      Map.get(changeset.data || %{}, :organization_id)
  end
end
