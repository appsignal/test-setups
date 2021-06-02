defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User

  def index(conn, _params) do
    pid = self()

    0..100
    |> Enum.map(fn i ->
      Async.Task.async(
        fn ->
          0..100
          |> Enum.map(fn j ->
            Async.Task.async(
              fn ->
                IO.puts("#{i}-#{j}")
              end,
              "#{i}-#{j}"
            )
          end)
        end,
        "#{i}"
      )
    end)

    0..1000
    |> Enum.map(fn i ->
      Task.async(fn ->
        time = :os.system_time()
        duration = :rand.uniform(1000)

        IO.puts(duration)

        "cache"
        |> Appsignal.Tracer.create_span(Appsignal.Tracer.current_span(pid),
          start_time: time - System.convert_time_unit(duration, :microsecond, :native)
        )
        |> Appsignal.Span.set_name("Cache")
        |> Appsignal.Span.set_attribute("appsignal:category", "command.cache")
        |> Appsignal.Span.set_attribute("appsignal:body", "body")
        |> Appsignal.Tracer.close_span(end_time: time)
      end)
    end)

    render(conn, "index.html", users: Accounts.list_users())
  end
end
