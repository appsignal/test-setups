defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/users")
  end
end
