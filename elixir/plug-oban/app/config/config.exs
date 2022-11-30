import Config

config :plug_oban, PlugOban.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: System.get_env("POSTGRES_DB", "db"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  port: System.get_env("POSTGRES_PORT", "5432")

config :plug_oban,
  ecto_repos: [PlugOban.Repo]

config :plug_oban, Oban,
  repo: PlugOban.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 3, slow: 1]

import_config "appsignal.exs"
