defmodule CloseTheLoop.Repo.Migrations.MigrateUserOrgMemberships do
  use Ecto.Migration

  def up do
    execute("""
    INSERT INTO user_organizations (id, user_id, organization_id, role, inserted_at, updated_at)
    SELECT
      gen_random_uuid(),
      id,
      organization_id,
      COALESCE(role, 'staff'),
      (now() AT TIME ZONE 'utc'),
      (now() AT TIME ZONE 'utc')
    FROM users
    WHERE organization_id IS NOT NULL
    ON CONFLICT (user_id, organization_id) DO NOTHING
    """)
  end

  def down do
    # No-op: we intentionally keep the join table rows.
  end
end
