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
    raise "This is an error!"
  end

  def slow_job(conn, _params) do
    TestApp.PerformanceWorker.new(%{a: "b"})
    |> Oban.insert()

    conn
    |> put_flash(:info, "Queued slow job")
    |> redirect(to: "/")
  end

  def timeout_job(conn, _params) do
    TestApp.TimeoutWorker.new(%{a: "b"})
    |> Oban.insert()

    conn
    |> put_flash(:info, "Queued timeout job")
    |> redirect(to: "/")
  end

  def error_job(conn, _params) do
    TestApp.ErrorWorker.new(%{a: "b"})
    |> Oban.insert()

    conn
    |> put_flash(:info, "Queued error job")
    |> redirect(to: "/")
  end

  def user_job(conn, _params) do
    TestApp.UserWorker.new(%{name: "Tom", email: "tom@example.com"})
    |> Oban.insert()

    conn
    |> put_flash(:info, "Queued user job")
    |> redirect(to: "/")
  end
end
