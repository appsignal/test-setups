defmodule AppsignalAbsinthePlug do
  alias Appsignal.Transaction

  def init(_), do: nil
    
  @path "/api" # Change me to your route's path

  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    Appsignal.Plug.put_name(conn, "POST " <> @path)
  end

  def call(conn, _) do
    conn
  end
end 
