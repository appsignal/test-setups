defmodule BroadwayExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :broadway_example,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BroadwayExample.Application, []}
    ]
  end

  defp integration_path do
    System.get_env("INTEGRATION_PATH", "../../integration")
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 1.3.0"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"},
      {:appsignal, path: "#{integration_path()}/appsignal-elixir", override: true},
      {:appsignal_plug, path: "#{integration_path()}/appsignal-elixir-plug"}
    ]
  end
end
