defmodule CloseTheLoop.Accounts.OrganizationInvitation.Validations.InviteeCanAccept do
  @moduledoc false

  use Ash.Resource.Validation

  alias CloseTheLoop.Accounts.OrganizationInvitation

  @impl true
  def init(opts), do: {:ok, opts}

  @impl true
  def validate(changeset, _opts, context) do
    actor = context.actor
    invite = changeset.data

    cond do
      is_nil(actor) ->
        {:error,
         Ash.Error.Forbidden.exception(message: "You must be signed in to accept an invite.")}

      not match?(%OrganizationInvitation{}, invite) ->
        {:error, Ash.Error.Forbidden.exception(message: "Invitation not found.")}

      not is_nil(invite.revoked_at) ->
        {:error, invalid("This invitation has been revoked.")}

      not is_nil(invite.accepted_at) ->
        {:error, invalid("This invitation has already been accepted.")}

      expired?(invite) ->
        {:error, invalid("This invitation has expired.")}

      true ->
        :ok
    end
  end

  defp expired?(%OrganizationInvitation{expires_at: %DateTime{} = expires_at}) do
    DateTime.compare(expires_at, DateTime.utc_now()) != :gt
  end

  defp expired?(_), do: true

  defp invalid(message) when is_binary(message) do
    Ash.Error.Changes.InvalidChanges.exception(fields: [:token], message: message)
  end
end
