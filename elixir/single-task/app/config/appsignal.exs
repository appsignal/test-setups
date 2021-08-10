use Mix.Config

config :appsignal, :config,
  active: true,
  otp_app: :single_task,
  env: Mix.env,
  debug: true,
  transaction_debug_mode: true
