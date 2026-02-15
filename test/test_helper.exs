ExUnit.start()

# Mix starts the application for tests, but we need the repo up
# before we can run our tenant migrations.
{:ok, _apps} = Application.ensure_all_started(:close_the_loop)

# For schema-based multitenancy, tenant resources live in Postgres schemas.
# In tests we run tenant migrations against `public` so we can use `tenant: "public"`
# without needing to create/manage schemas per test case.
#
# We temporarily put the sandbox in :auto mode to run migrations without an owner.
Ecto.Adapters.SQL.Sandbox.mode(CloseTheLoop.Repo, :auto)

Ecto.Migrator.with_repo(CloseTheLoop.Repo, fn repo ->
  Ecto.Migrator.run(repo, "priv/repo/tenant_migrations", :up, all: true)
end)

Ecto.Adapters.SQL.Sandbox.mode(CloseTheLoop.Repo, :manual)
