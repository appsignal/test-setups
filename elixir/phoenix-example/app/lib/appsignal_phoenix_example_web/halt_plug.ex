defmodule HaltPlug do
  def init(options), do: options

  def call(%Plug.Conn{request_path: "/halt"} = conn, opts) do
    Appsignal.Tracer.root_span()
    |> Appsignal.Span.set_name("halted")

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, "Halted!")
    |> Plug.Conn.halt()
  end

  def call(conn, opts) do
    conn
  end
end
