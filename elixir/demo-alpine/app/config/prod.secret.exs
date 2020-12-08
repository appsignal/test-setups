# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

config :demo, Demo.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: System.get_env("POSTGRES_DB"),
  hostname: "postgres",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :demo, DemoWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000")
  ]

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:

config :demo, DemoWeb.Endpoint, server: true
