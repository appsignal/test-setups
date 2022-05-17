defmodule App do
  use Plug.Router
  use Appsignal.Plug

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/already-sent" do
    send_resp(conn, 200, "Welcome")

    raise "Already sent!"
  end
end
