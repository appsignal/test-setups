defmodule ElixirPhoenixOpentelemetryWeb.PageController do
  use ElixirPhoenixOpentelemetryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    render(conn, "slow.html")
  end

  def error(_conn, _params) do
    raise "This is a Phoenix error!"
  end
end
