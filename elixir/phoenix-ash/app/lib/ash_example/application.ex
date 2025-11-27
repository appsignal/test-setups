defmodule AshExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshExampleWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:ash_example, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshExample.PubSub},
      # Start a worker by calling: AshExample.Worker.start_link(arg)
      # {AshExample.Worker, arg},
      # Start to serve requests, typically the last entry
      AshExampleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
