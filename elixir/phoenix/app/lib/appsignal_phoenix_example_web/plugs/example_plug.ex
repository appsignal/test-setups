defmodule AppsignalPhoenixExampleWeb.Plugs.ExamplePlug do
  import Plug.Conn

  def init(options), do: options

  def call(%{request_path: "/plug"} = conn, _options) do
    Appsignal.instrument("plug", fn ->
      conn
    end)
  end

  def call(conn, _options) do
    conn
  end
end
