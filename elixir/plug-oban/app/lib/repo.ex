defmodule PlugOban.Repo do
  use Ecto.Repo,
    otp_app: :plug_oban,
    adapter: Ecto.Adapters.Postgres
end
