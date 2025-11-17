import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ash_example, AshExampleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "hoRQU03vHxAf/CGlJXRPnd1RnXgmLtA8dVCWa5AGMgGr5en9Q/WdsLyDTuXpyI2t",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
