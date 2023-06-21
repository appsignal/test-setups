defmodule ChipWeb.CustomPlug do
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(%Conn{path_info: ["custom"]} = conn, _opts) do
    # TODO: this instrumentation doesn't seem to make it to AppSignal
    Appsignal.instrument("ChipWeb.CustomPlug", fn ->
      Process.sleep(1000)
      |> Appsignal.Span.set_namespace("web")
      |> Appsignal.Span.set_name("custom")

      conn
      |> Conn.send_resp(200, "special case handling of /custom endpoint")
      |> Conn.halt()
    end)
  end

  def call(%Conn{} = conn, _opts) do
    conn
  end
end
