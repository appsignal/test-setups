defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
