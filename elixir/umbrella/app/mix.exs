defmodule Mywebsite.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:appsignal_plug, path: "#{integration_path()}/appsignal-elixir-plug"}
    ]
  end
end
