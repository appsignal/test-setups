defmodule PlugOban.Router do
  use Plug.Router
  use Appsignal.Plug

  plug :match
  plug :dispatch

  get "/" do
    resp = """
      <html>
      <h1>Plug + Oban</h1>

      <form method="POST" action="/queue">
        <input type="submit" style="background-color: greenyellow;" value="Add some jobs"></input>
      </form>
      <form method="POST" action="/queue/fail">
        <input type="submit" style="background-color: hotpink;" value="Add some failing jobs"></input>
      </form>
      <form method="POST" action="/queue/many">
        <input type="submit" style="background-color: cornflowerblue;" value="Add way too many jobs"></input>
      </form>
      <form method="POST" action="/queue/slow">
        <input type="submit" style="background-color: salmon;" value="Add some jobs to the slow queue"></input>
      </form>
      <form method="POST" action="/queue/one">
        <input type="submit" style="background-color: greenyellow;" value="Add just one job"></input>
      </form>

      </html>
    """

    send_resp(conn, 200, resp)
  end

  get "/slow" do
    :timer.sleep(3000)

    send_resp(conn, 200, "Welp, that took forever!")
  end

  get "/error" do
    raise "Whoops!"
  end

  post "/queue/one" do
    queue_one_job()

    send_resp(conn, 200, "Added one job to default queue!")
  end

  post "/queue" do
    queue_some_jobs(%{}, [])

    send_resp(conn, 200, "Added some jobs to default queue!")
  end

  post "/queue/fail" do
    queue_some_jobs(%{fail: true}, [])
    
    send_resp(conn, 200, "Added some *failing* jobs to default queue!")
  end

  post "/queue/many" do
    Enum.each(1..10, fn _ -> queue_some_jobs(%{}, []) end)

    send_resp(conn, 200, "Added *many* jobs to default queue!")
  end

  post "/queue/slow" do
    queue_some_jobs(%{}, queue: :slow)

    send_resp(conn, 200, "Added some jobs to *slow* queue!")
  end

  def queue_some_jobs(args, opts) do
    times = 1..Enum.random(1..10)

    Enum.each(times, fn _ -> 
      numbers = Enum.map(1..5, fn _ -> Enum.random(1..500) end)

      %{numbers: numbers}
        |> Map.merge(args)
        |> PlugOban.AddTask.new(opts)
        |> Oban.insert()
    end)
    
    times = 1..Enum.random(1..10)

    Enum.each(times, fn _ -> 
      numbers = Enum.map(1..5, fn _ -> Enum.random(1..500) end)

      %{numbers: numbers}
        |> Map.merge(args)
        |> PlugOban.AverageTask.new(opts)
        |> Oban.insert()
    end)
  end

  def queue_one_job do
    numbers = Enum.map(1..5, fn _ -> Enum.random(1..500) end)

    %{numbers: numbers}
      |> PlugOban.AddTask.new()
      |> Oban.insert()
  end
  
  match _ do
    conn
      |> put_resp_header("Location", "/")
      |> send_resp(302, "Redirecting to /")
  end
end
