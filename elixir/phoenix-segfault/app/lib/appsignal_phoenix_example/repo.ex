defmodule AppsignalPhoenixExample.Repo do
  use Ecto.Repo,
    otp_app: :appsignal_phoenix_example,
    adapter: Ecto.Adapters.Postgres
end
