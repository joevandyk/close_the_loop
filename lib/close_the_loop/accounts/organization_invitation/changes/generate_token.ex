defmodule CloseTheLoop.Accounts.OrganizationInvitation.Changes.GenerateToken do
  @moduledoc false

  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :token) do
      token when is_binary(token) and token != "" ->
        changeset

      _ ->
        Ash.Changeset.force_change_attribute(changeset, :token, Ash.UUID.generate())
    end
  end
end
