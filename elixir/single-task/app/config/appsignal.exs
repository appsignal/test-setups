import Config

config :appsignal, :config,
  active: true,
  otp_app: :single_task,
  env: Mix.env
