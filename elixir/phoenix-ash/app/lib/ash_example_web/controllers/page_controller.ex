defmodule AshExampleWeb.PageController do
  use AshExampleWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    text(conn, "That took forever!")
  end

  def error(_conn, _params) do
    raise "Oops!"
  end
end
