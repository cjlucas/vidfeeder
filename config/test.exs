use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vidfeeder, VidFeederWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :vidfeeder, VidFeeder.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "vidfeeder_test",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, :console,
  format: "\n$time $metadata[$level] $levelpad$message\n",
  metadata: [:event, :context, :metadata, :pid]
