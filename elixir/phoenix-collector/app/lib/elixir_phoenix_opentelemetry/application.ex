defmodule ElixirPhoenixOpentelemetry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirPhoenixOpentelemetryWeb.Telemetry,
      ElixirPhoenixOpentelemetry.Repo,
      {DNSCluster, query: Application.get_env(:elixir_phoenix_opentelemetry, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirPhoenixOpentelemetry.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirPhoenixOpentelemetry.Finch},
      # Start a worker by calling: ElixirPhoenixOpentelemetry.Worker.start_link(arg)
      # {ElixirPhoenixOpentelemetry.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirPhoenixOpentelemetryWeb.Endpoint
    ]

    OpentelemetryBandit.setup()
    OpentelemetryPhoenix.setup(adapter: :bandit, liveview: true)
    OpentelemetryPhoenixController.setup()
    OpentelemetryEcto.setup([:elixir_phoenix_opentelemetry, :repo])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirPhoenixOpentelemetry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirPhoenixOpentelemetryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
