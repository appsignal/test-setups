defmodule PlugOban.Application do
  use Application

  require Logger

  def start(_type, _args) do
    children = [
      PlugOban.Repo,
      {Oban, Application.fetch_env!(:plug_oban, Oban)},
      {Plug.Cowboy, scheme: :http, plug: PlugOban.Router, options: [port: 4000]}
    ]

    Logger.info("Listening on http://localhost:4001")

    Supervisor.start_link(children, strategy: :one_for_one, name: PlugOban.Supervisor)
  end
end
