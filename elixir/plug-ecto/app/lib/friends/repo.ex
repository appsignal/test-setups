defmodule Friends.Repo do
  use Appsignal.Ecto.Repo,
    otp_app: :plug_example,
    adapter: Ecto.Adapters.Postgres
end
