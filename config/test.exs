import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

config :alternis, game_flow: Alternis.Engines.GameEngine.Mock
config :alternis, game_engine: Alternis.Engines.GameEngine.Mock
config :alternis, match_engine: Alternis.Engines.MatchEngine.Mock

config :alternis, Alternis.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "alternis_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :alternis, Oban, testing: :inline

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :alternis, AlternisWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "e9b8n5n2ytFjQVkyLOZyy5AGMIgj+kwhj1eN8kIZXzwJpRMlpJ2REmaC4dbrE0WQ",
  server: false

# In test we don't send emails.
config :alternis, Alternis.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
