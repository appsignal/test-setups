defmodule PlugExample do
  use Plug.Router
  use Appsignal.Plug

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello world")
  end
end
