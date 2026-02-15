# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CloseTheLoop.Repo.insert!(%CloseTheLoop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

if Mix.env() == :prod and System.get_env("ALLOW_PROD_SEEDS") != "true" do
  raise """
  Refusing to run seeds in :prod.

  If you are *sure* you want this, re-run with:
    ALLOW_PROD_SEEDS=true mix run priv/repo/seeds.exs
  """
end

{:ok, _} = Application.ensure_all_started(:close_the_loop)

org = CloseTheLoop.DevSeeds.run()

require Ash.Query

tenant = org.tenant_schema

mens_full_path = "Demo Facility / Locker Rooms / Mens Locker Room"

mens =
  CloseTheLoop.Feedback.Location
  |> Ash.Query.filter(full_path == ^mens_full_path)
  |> Ash.read_one!(tenant: tenant)

IO.puts("""

Seeded:
  org.name=#{org.name}
  org.tenant_schema=#{org.tenant_schema}

Try:
  /sign-in
  /app/onboarding
  /app/issues
  /app/locations

Reporter link (example):
  /r/#{tenant}/#{mens && mens.id}
""")
