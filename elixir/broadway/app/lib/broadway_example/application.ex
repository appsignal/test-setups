defmodule BroadwayExample.Application do
  @moduledoc false

  use Application

  require Logger

  @impl Application
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4000")

    children = [
      BroadwayExample.Stats,
      {Registry, keys: :unique, name: BroadwayExample.Registry},
      BroadwayExample.Pipeline,
      # The same pipeline a second time, under a `{:via, Registry, ...}` name
      # rather than an atom.
      Supervisor.child_spec(
        {BroadwayExample.Pipeline, name: BroadwayExample.Pipeline.registered_name()},
        id: :registered_pipeline
      ),
      {Plug.Cowboy, scheme: :http, plug: BroadwayExample.Router, options: [port: port]}
    ]

    Logger.info("Listening on http://localhost:#{port}")

    Supervisor.start_link(children, strategy: :one_for_one, name: BroadwayExample.Supervisor)
  end
end
