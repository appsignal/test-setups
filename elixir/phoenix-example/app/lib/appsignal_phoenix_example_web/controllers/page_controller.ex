defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User
  require Logger
  plug DemoPlug, "en"

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    render(conn, "slow.html")
  end

  def error(_conn, _params) do
    raise "This is a Phoenix error!"
  end

  def partials(conn, _params) do
    render(conn, "partials.html")
  end
end
