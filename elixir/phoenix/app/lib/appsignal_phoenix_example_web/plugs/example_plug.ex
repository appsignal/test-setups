defmodule AppsignalPhoenixExampleWeb.Plugs.ExamplePlug do
  import Plug.Conn

  def init(options), do: options

  def call(%{request_path: "/plug"} = conn, _options) do
    Appsignal.instrument("plug", fn ->
      conn
    end)
  end

  def call(%{request_path: "/plug/error"} = conn, _options) do
    try do
      raise "Error raised from ExamplePlug"
    catch
      kind, reason ->
	Appsignal.set_error(kind, reason, __STACKTRACE__)
    end

    conn
  end

  def call(conn, _options) do
    conn
  end
end
