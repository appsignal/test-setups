import Config

config :appsignal, :config,
  otp_app: :broadway_example,
  name: "elixir-broadway-2",
  push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY"),
  env: Mix.env(),
  active: true
