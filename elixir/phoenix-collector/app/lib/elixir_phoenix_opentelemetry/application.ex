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
    OpentelemetryEcto.setup([:elixir_phoenix_opentelemetry, :repo])

    # Setup OpenTelemetry log handler to send logs through OTLP
    setup_otel_log_handler()

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

  defp setup_otel_log_handler do
    handler_config = %{
      id: :otel_logs,
      module: :otel_log_handler,
      config: %{
        exporter: {:otel_exporter_logs_otlp, %{protocol: :http_protobuf}},
        max_queue_size: 2048,
        exporting_timeout_ms: 30_000,
        scheduled_delay_ms: 5_000
      }
    }

    case :logger.add_handler(:otel_logs, :otel_log_handler, handler_config) do
      :ok ->
        :ok

      {:error, {:already_exist, :otel_logs}} ->
        :ok

      {:error, reason} ->
        IO.warn("Failed to add OpenTelemetry log handler: #{inspect(reason)}")
        :ok
    end
  end
end
