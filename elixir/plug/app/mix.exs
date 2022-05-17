defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {App.Application, []}
    ]
  end

  defp integration_path do
    System.get_env("INTEGRATION_PATH", "../../integration")
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:appsignal, path: "#{integration_path()}/appsignal-elixir", override: true},
      {:appsignal_plug, path: "#{integration_path()}/appsignal-elixir-plug", override: true}
    ]
  end
end
