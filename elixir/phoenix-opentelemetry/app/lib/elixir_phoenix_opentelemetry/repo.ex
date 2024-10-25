defmodule ElixirPhoenixOpentelemetry.Repo do
  use Ecto.Repo,
    otp_app: :elixir_phoenix_opentelemetry,
    adapter: Ecto.Adapters.Postgres
end
