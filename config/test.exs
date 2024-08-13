import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :basket, Basket.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "basket_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :basket, BasketWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/3f0zcmrIS+tGge9feecbbsNUisoxkK9vJcinWu6khrqF2QkoA4w4mSmec83UjPt",
  server: false

# In test we don't send emails.
config :basket, Basket.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :basket, :alpaca,
  api_key: "api-key",
  api_secret: "api-secret",
  data_http_url: "https://test-suite-data.alpaca.markets",
  market_http_url: "https://test-suite-api.alpaca.markets",
  market_ws_url: "wss://test-suite-stream.data.alpaca.markets/v2"

# This stub keeps the test app supervisor happy during startup
config :basket, :websocket_client, Basket.Support.MockWebsocketClient

config :basket, Oban, testing: :inline
