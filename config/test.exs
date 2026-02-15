import Config
config :close_the_loop, Oban, testing: :manual
config :close_the_loop, token_signing_secret: "vT6qjDOO6tOcX6j3iRCHImOHr2ZDAtxE"
config :bcrypt_elixir, log_rounds: 1
config :ash, policies: [show_policy_breakdowns?: true], disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
partition = System.get_env("MIX_TEST_PARTITION") || ""
test_db = "close_the_loop_test#{partition}"

database_url = System.get_env("DATABASE_URL")

repo_opts =
  if database_url do
    uri = URI.parse(database_url)
    [url: URI.to_string(%{uri | path: "/" <> test_db})]
  else
    [
      username: "postgres",
      password: "postgres",
      hostname: "localhost",
      database: test_db
    ]
  end

config :close_the_loop,
       CloseTheLoop.Repo,
       Keyword.merge(
         [
           pool: Ecto.Adapters.SQL.Sandbox,
           pool_size: System.schedulers_online() * 2
         ],
         repo_opts
       )

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :close_the_loop, CloseTheLoopWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PjSx6s5GklZ2Oth5flz1hM9mLe2Rf9rvIK1TCKaYSvPxe6CS3x+0o7Zi9pnZP8hv",
  server: false

# In test we don't send emails
config :close_the_loop, CloseTheLoop.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
