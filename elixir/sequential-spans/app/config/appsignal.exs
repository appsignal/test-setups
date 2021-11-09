use Mix.Config

config :appsignal, :config,
  active: true,
  otp_app: :sequential_spans,
  env: Mix.env(),
  debug: true,
  transaction_debug_mode: true
