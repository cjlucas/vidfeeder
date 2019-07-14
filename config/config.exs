# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :vidfeeder, VidFeeder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "vidfeeder_repo",
  username: "user",
  password: "pass",
  hostname: "localhost",
  migration_primary_key: [id: :uuid, type: :binary_id],
  migration_timestamps: [type: :utc_datetime],
  timeout: 60_000,
  pool_timeout: 60_000


# General application configuration
config :vidfeeder,
  namespace: VidFeeder,
  ecto_repos: [VidFeeder.Repo]

# Configures the endpoint
config :vidfeeder, VidFeederWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BDAW+rSWbqwOeFfJB1y/+dJQho/KVoVMkdNgnG2htap2InoOAAGavmS+1qyD5+dS",
  render_errors: [view: VidFeederWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VidFeeder.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: {VidFeeder.LogFormatter, :format},
  metadata: [:user_id]

# Temp for testing
config :hackney, max_connections: 250

config :cipher,
  keyphrase: System.get_env("CIPHER_KEY_PHRASE"),
  ivphrase: System.get_env("CIPHER_IV_PHRASE")

config :goth,
  config_module: VidFeeder.GothConfig

config :sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")

config :logger,
  backends: [:console],
  utc_log: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
