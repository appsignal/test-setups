defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User

  def index(conn, _params) do
    render(conn, "index.html", users: Accounts.list_users())
  end
end
