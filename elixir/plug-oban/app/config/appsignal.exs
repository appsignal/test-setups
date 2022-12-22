use Mix.Config

config :appsignal, :config,
  active: true,
  otp_app: :plug_oban,
  env: Mix.env

