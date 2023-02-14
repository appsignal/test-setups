defmodule PlugExample do
  use Plug.Router
  use Appsignal.Plug

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello world")
  end

  get "/slow" do
    :timer.sleep(3000)

    send_resp(conn, 200, "Welp, that took forever!")
  end

  get "/error" do
    raise "Whoops!"
  end
end
