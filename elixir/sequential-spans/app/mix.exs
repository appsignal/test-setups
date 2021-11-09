defmodule SequentialSpans.MixProject do
  use Mix.Project

  def project do
    [
      app: :sequential_spans,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:appsignal, path: "/integration/appsignal-elixir", override: true}
    ]
  end
end
