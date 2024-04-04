defmodule TestAppWeb.PageController do
  use TestAppWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    render(conn, "slow.html")
  end

  def error(_conn, _params) do
    raise "This is a Phoenix error!"
  end
end
