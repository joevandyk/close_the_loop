# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ash_oban, pro?: false

# Fluxon UI: translate Phoenix validation errors via our Gettext backend.
# See https://docs.fluxonui.com/gettext.html
config :fluxon, :translate_function, &CloseTheLoopWeb.CoreComponents.translate_error/1

config :close_the_loop, Oban,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  queues: [default: 10],
  repo: CloseTheLoop.Repo,
  plugins: [{Oban.Plugins.Cron, []}]

config :ash,
  allow_forbidden_field_for_relationships_by_default?: true,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  keep_read_action_loads_when_loading?: false,
  default_actions_require_atomic?: true,
  read_action_after_action_hooks_in_order?: true,
  bulk_actions_default_to_errors?: true,
  transaction_rollback_on_error?: true,
  known_types: [AshPostgres.Timestamptz, AshPostgres.TimestamptzUsec]

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :authentication,
        :token,
        :user_identity,
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [section_order: [:resources, :policies, :authorization, :domain, :execution]]
  ]

config :close_the_loop,
  ecto_repos: [CloseTheLoop.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [CloseTheLoop.Accounts, CloseTheLoop.Tenants, CloseTheLoop.Feedback],
  ash_authentication: [return_error_on_invalid_magic_link_token?: true]

config :ex_twilio,
  account_sid: {:system, "TWILIO_ACCOUNT_SID"},
  auth_token: {:system, "TWILIO_AUTH_TOKEN"}

# Configure the endpoint
config :close_the_loop, CloseTheLoopWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CloseTheLoopWeb.ErrorHTML, json: CloseTheLoopWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CloseTheLoop.PubSub,
  live_view: [signing_salt: "oj8OGGib"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :close_the_loop, CloseTheLoop.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  close_the_loop: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" => [
        Path.expand("../deps", __DIR__),
        Path.expand("../vendor", __DIR__),
        Mix.Project.build_path()
      ]
    }
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  close_the_loop: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
