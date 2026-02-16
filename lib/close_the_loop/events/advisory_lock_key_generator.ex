defmodule CloseTheLoop.Events.AdvisoryLockKeyGenerator do
  @moduledoc false

  use AshEvents.AdvisoryLockKeyGenerator

  @max_32_bit_signed 2_147_483_647

  @impl true
  def generate_key!(%{tenant: tenant} = changeset, default_integer) when is_binary(tenant) do
    # AshEvents' default advisory lock key generator returns the same lock key for
    # context-based multitenancy. Our tenants are strings (Postgres schemas like "org_demo"),
    # so we derive a stable per-tenant lock key to reduce cross-tenant contention.
    case Ecto.UUID.cast(tenant) do
      {:ok, _uuid} ->
        AshEvents.AdvisoryLockKeyGenerator.Default.generate_key!(changeset, default_integer)

      :error ->
        [
          :erlang.phash2({tenant, 1}, @max_32_bit_signed),
          :erlang.phash2({tenant, 2}, @max_32_bit_signed)
        ]
    end
  end

  def generate_key!(changeset_or_resource, default_integer) do
    AshEvents.AdvisoryLockKeyGenerator.Default.generate_key!(
      changeset_or_resource,
      default_integer
    )
  end
end
