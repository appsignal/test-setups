defmodule Friends.Repo do
  use Ecto.Repo,
    otp_app: :plug_example,
    adapter: Ecto.Adapters.Postgres
end
