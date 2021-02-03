defmodule Gateway.Plug.Absinthe do
  import Plug.Conn
  require Logger

  def init(_), do: nil

  @path "/api"

  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    Appsignal.instrument "Gateway.AbsintheController#query", fn ->
      Appsignal.Plug.put_name(conn, "POST " <> @path)
      conn
    end
  end

  def call(conn, _) do
    conn
  end
end
