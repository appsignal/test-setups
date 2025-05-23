defmodule PlugExample do
  use Plug.Router
  use Appsignal.Plug
  import Ecto.Query
  alias Friends.{Repo, Movie}

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, """
      <h1>Plug + Ecto test setup</h1>

      <ul>
        <li><a href="/preload"><kbd>/preload</kbd></a>: Perform an Ecto preload query
        <li><a href="/transaction"><kbd>/transaction</kbd></a>: Perform an Ecto transaction query
      </ul>
    """
    )
  end

  get "/slow" do
    :timer.sleep(3000)

    send_resp(conn, 200, "Welp, that took forever!")
  end

  get "/error" do
    raise "Whoops!"
  end

  get "/preload" do
    movies = Repo.all(from m in Movie, preload: [:characters, :actors])

    send_resp(conn, 200, "<p>Here's some movies for you:</p><pre>#{inspect(movies)}</pre>")
  end

  get "/transaction" do
    Repo.transaction(fn ->
      Repo.insert!(%Movie{title: "The Room"})
      Repo.insert!(%Movie{title: "The Disaster Artist"})
    end)

    send_resp(conn, 200, "<p>Inserted some movies in a transaction!</p>")
  end
end
