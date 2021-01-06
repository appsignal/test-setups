defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User

  plug DemoPlug, "en"

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def custom(conn, _params) do
    conn
  |> send_resp(201, "special case handling of /custom endpoint")
  end
end
