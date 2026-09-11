defmodule BroadwayExample.Router do
  @moduledoc """
  A small web interface for the pipeline.

  Broadway has no HTTP surface of its own; this exists so the test setup has an
  index page to serve, and because it is the only way messages enter the
  pipeline: the producer generates nothing on its own.
  """

  use Plug.Router
  use Appsignal.Plug

  alias BroadwayExample.{Event, Producer, Stats}

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, index())
  end

  get "/push" do
    push_payments(1)

    redirect(conn, "Pushed 1 payment")
  end

  get "/push/failing" do
    push_payments(1, %{fail: true})

    redirect(conn, "Pushed 1 failing payment")
  end

  get "/push/burst" do
    push_payments(500)

    redirect(conn, "Pushed 500 payments")
  end

  get "/topology" do
    topology = BroadwayExample.Pipeline |> Broadway.topology() |> inspect(pretty: true)

    send_resp(conn, 200, "<h1>Topology</h1><pre>#{topology}</pre><a href=\"/\">Back</a>")
  end

  get "/error" do
    raise "Whoops! Raised in #{conn.request_path}"
  end

  match _ do
    conn
    |> put_resp_header("location", "/")
    |> send_resp(302, "Redirecting to /")
  end

  defp push_payments(count, overrides \\ %{}) do
    count |> Event.random_batch(overrides) |> Producer.push()
  end

  defp redirect(conn, message) do
    conn
    |> put_resp_header("location", "/")
    |> send_resp(302, message)
  end

  defp index do
    stats = Stats.all()

    """
    <html>
    <head><title>Broadway test app</title></head>
    <body>
      <h1>Broadway test app</h1>

      <p>
        Push payment events with the links below. Two processors enrich each one
        and hand it to the <code>:default</code> batcher, which settles them in
        batches. Nothing happens until you push.
      </p>

      <h2>Counters</h2>
      <ul>
        <li>Produced: #{stats[:produced]}</li>
        <li>Processed: #{stats[:processed]}</li>
        <li>Batched: #{stats[:batched]}</li>
        <li>Acked: #{stats[:acked]}</li>
        <li>Failed: #{stats[:failed]}</li>
        <li>Waiting in the producer: #{stats[:queue_size]}</li>
      </ul>

      <h2>Push messages</h2>
      <ul>
        <li><a href="/push">GET /push</a> &mdash; 1 payment</li>
        <li><a href="/push/failing">GET /push/failing</a> &mdash; 1 payment that raises in the processor</li>
        <li><a href="/push/burst">GET /push/burst</a> &mdash; 500 payments at once</li>
      </ul>

      <h2>Other</h2>
      <ul>
        <li><a href="/topology">GET /topology</a> &mdash; the running Broadway topology</li>
        <li><a href="/error">GET /error</a> &mdash; raise in the web request</li>
      </ul>
    </body>
    </html>
    """
  end
end
