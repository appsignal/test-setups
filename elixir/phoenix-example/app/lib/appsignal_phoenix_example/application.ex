defmodule AppsignalPhoenixExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Appsignal.Phoenix.LiveView.attach()

    children = [
      # Start the Ecto repository
      AppsignalPhoenixExample.Repo,
      # Start the Telemetry supervisor
      AppsignalPhoenixExampleWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AppsignalPhoenixExample.PubSub},
      # Start the Endpoint (http/https)
      AppsignalPhoenixExampleWeb.Endpoint,
      # Start a worker by calling: AppsignalPhoenixExample.Worker.start_link(arg)
      # {AppsignalPhoenixExample.Worker, arg}
      # Start Finch HTTP client
      {Finch, name: MyFinch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AppsignalPhoenixExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AppsignalPhoenixExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
