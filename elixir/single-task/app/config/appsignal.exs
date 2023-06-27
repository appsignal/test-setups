use Mix.Config

config :appsignal, :config,
  active: true,
  otp_app: :single_task,
  env: Mix.env,
  transaction_debug_mode: true
