defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User
  require Logger
  plug DemoPlug, "en"

  def index(conn, _params) do
    users = Accounts.list_users()
    slow()
    render(conn, "index.html", users: users)
  end

  defp slow do
    Appsignal.instrument("slow", fn ->
      :timer.sleep(1000)
    end)

    Appsignal.instrument("slow_2", fn ->
      :timer.sleep(1000)
    end)

    Appsignal.instrument("slow_3", fn ->
      :timer.sleep(1000)
    end)
  end
end
