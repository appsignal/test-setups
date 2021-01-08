defmodule AppsignalAbsinthePlug do
  alias Appsignal.Transaction

  def init(_), do: nil

  @path "/api" # Change me to your route's path

  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    Appsignal.instrument "AppsignalAbsinthePlug", fn ->
      Appsignal.Plug.put_name(conn, "POST " <> @path)
      conn
    end
  end

  def call(conn, _) do
    conn
  end
end
