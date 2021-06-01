defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User

  def index(conn, _params) do
    tasks =
      0..1_000
      |> Enum.map(fn i ->
        Async.Task.async(
          fn ->
            IO.puts(i)
          end,
          "label"
        )
      end)

    tasks

    Enum.each(tasks, fn task ->
      Async.Task.await(task, 5000)
    end)

    render(conn, "index.html", users: Accounts.list_users())
  end
end
