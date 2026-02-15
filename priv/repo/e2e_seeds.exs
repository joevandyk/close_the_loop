# E2E seed data for Playwright.
#
# This script is intended to run in MIX_ENV=dev as part of the Playwright webServer
# command. It:
# - ensures a confirmed password user we can sign in with (so e2e doesn't need /dev/mailbox)
# - deletes any prior E2E organizations/schemas so runs don't slow down over time
# - clears the user's org so onboarding creates a brand-new org each run

alias CloseTheLoop.Repo

{:ok, _} = Application.ensure_all_started(:close_the_loop)

email = System.get_env("E2E_USER_EMAIL", "e2e_owner@example.com")
password = System.get_env("E2E_USER_PASSWORD", "password1234")

hashed = Bcrypt.hash_pwd_salt(password)
now = DateTime.utc_now()
id = Ecto.UUID.bingenerate()

# Clean up prior E2E orgs/schemas so runs stay fast.
#
# We only touch orgs with names starting with "[E2E]" to avoid deleting developer data.
e2e_org_rows =
  Repo.query!("SELECT tenant_schema FROM organizations WHERE name LIKE '[E2E]%'").rows

Enum.each(e2e_org_rows, fn
  [schema] when is_binary(schema) ->
    if Regex.match?(~r/^[a-z0-9_]+$/, schema) do
      Repo.query!("DROP SCHEMA IF EXISTS \"#{schema}\" CASCADE")
    end

  _ ->
    :ok
end)

Repo.query!("DELETE FROM organizations WHERE name LIKE '[E2E]%'")

Repo.query!(
  """
  INSERT INTO users (id, email, hashed_password, confirmed_at)
  VALUES ($1, $2, $3, $4)
  ON CONFLICT (email)
  DO UPDATE SET hashed_password = EXCLUDED.hashed_password,
                confirmed_at = EXCLUDED.confirmed_at
  """,
  [id, email, hashed, now]
)

IO.puts("E2E seed user ensured (password auth): #{email}")

# Force onboarding to run every time by clearing org assignment.
Repo.query!("UPDATE users SET organization_id = NULL, role = NULL WHERE email = $1", [email])
IO.puts("E2E user org cleared (onboarding will create a new org).")

