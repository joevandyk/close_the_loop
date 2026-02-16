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

orgs = CloseTheLoop.DevSeeds.run_all_sample_orgs!()
dev_logins = CloseTheLoop.DevSeeds.ensure_dev_users_for_orgs!(orgs)

require Ash.Query

demo_tenant = hd(orgs).tenant_schema
mens_full_path = "Demo Facility / Locker Rooms / Mens Locker Room"

mens =
  CloseTheLoop.Feedback.Location
  |> Ash.Query.filter(full_path == ^mens_full_path)
  |> Ash.read_one!(tenant: demo_tenant)

IO.puts("""

Seeded organizations (each has an owner; sign in with that email to see that org):
#{Enum.map_join(dev_logins, "\n", fn l -> "  #{l.org_name}  → #{l.email} / #{l.password}" end)}

Dev logins (all use same password):
  /sign-in → see table above

Try:
  /sign-in
  /app/issues
  /app/locations

Reporter link (example, Demo org):
  /r/#{demo_tenant}/#{mens && mens.id}
""")
