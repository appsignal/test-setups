defmodule PlugExample do
  use Plug.Router
  use Appsignal.Plug

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello world")
  end

  get "/slow" do
    :timer.sleep(3000)

    send_resp(conn, 200, "Welp, that took forever!")
  end

  get "/error" do
    raise "Whoops!"
  end

  get "/cron" do
    Appsignal.CheckIn.cron("custom-cron-checkin", fn ->
      :timer.sleep(3000)
    end)

    send_resp(conn, 200, "Cron check-in sent!")
  end

  get "/heartbeat" do
    Appsignal.CheckIn.heartbeat("custom-heartbeat-checkin")

    send_resp(conn, 200, "Heartbeat check-in sent!")
  end

  get "/custom_instrumentation" do
    Appsignal.Span.set_namespace(Appsignal.Tracer.root_span(), "custom")

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "tags",
      %{
        tag1: "value1",
        tag2: 123
      }
    )

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "params",
      %{
        query: "something to search for",
        language: "en_US"
      }
    )

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "session_data",
      %{
        session: %{
          user_id: "123",
          menu_collapsed: true
        }
      }
    )

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "custom_data",
      %{
        custom: %{
          data: "test",
          more: "data"
        }
      }
    )

    Appsignal.instrument("event.custom", fn ->
      :timer.sleep(100)

      Appsignal.instrument("nested.custom", fn ->
        :timer.sleep(100)
      end)

      Appsignal.instrument("Build complicated SQL query", "prepare_query.sql", fn span ->
        Appsignal.Span.set_sql(span, "SOME complicate SQL query")
      end)
    end)

    send_resp(conn, 200, "Tracked some code with custom instrumentation")
  end
end
