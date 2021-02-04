defmodule Gateway.Plug.Absinthe do
  import Plug.Conn
  require Logger
  alias Appsignal.Transaction

  def init(opts), do: opts

  @path "/api"
  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    conn
    |> Appsignal.Plug.put_name("Gateway.AbsintheController#query")
  end

  def call(conn, _), do: conn
end
