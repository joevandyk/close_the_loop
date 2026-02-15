defmodule CloseTheLoop.Repo do
  use AshPostgres.Repo,
    otp_app: :close_the_loop

  import Ecto.Query, only: [from: 2]

  @impl true
  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions", "citext"]
  end

  # Don't open unnecessary transactions
  # will default to `false` in 4.0
  @impl true
  def prefer_transaction? do
    false
  end

  @impl true
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end

  @impl true
  def all_tenants do
    # Used by generated tenant migrations in priv/repo/tenant_migrations.
    all(from(o in "organizations", select: o.tenant_schema))
  end
end
