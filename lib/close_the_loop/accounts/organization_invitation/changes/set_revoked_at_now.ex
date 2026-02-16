defmodule CloseTheLoop.Accounts.OrganizationInvitation.Changes.SetRevokedAtNow do
  @moduledoc false

  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.force_change_attribute(changeset, :revoked_at, DateTime.utc_now())
  end
end
