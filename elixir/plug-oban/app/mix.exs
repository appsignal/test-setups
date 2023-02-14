defmodule PlugOban.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_oban,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PlugOban.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp integration_path do
    System.get_env("INTEGRATION_PATH", "../../integration")
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.6.0"},
      {:oban, "~> 2.13"},
      {:jason, "~> 1.1"},
      {:appsignal, path: "#{integration_path()}/appsignal-elixir", override: true},
      {:appsignal_plug, path: "#{integration_path()}/appsignal-elixir-plug", override: true}
    ]
  end
end
