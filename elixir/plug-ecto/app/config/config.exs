import Config

config :plug_example, Friends.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: System.get_env("POSTGRES_DB", "plug_example_dev"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  port: System.get_env("POSTGRES_PORT", "5432")


config :plug_example,
  ecto_repos: [Friends.Repo]

config :appsignal, :config,
  otp_app: :plug_example
