use Mix.Config

config :appsignal, :config,
  otp_app: :appsignal_phoenix_example,
  name: "appsignal_phoenix_example",
  push_api_key: "e526dcd6-3d2e-41c7-91c4-4f6c3cedf7de",
  env: Mix.env,
  debug: true,
  transaction_debug_mode: true

