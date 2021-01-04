defmodule ChipWeb.CustomPlug do

  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    Appsignal.instrument "ChipWeb.CustomPlug", fn ->
      Process.sleep(1000)
      conn
    end
  end

  def call(%Conn{} = conn, _opts) do
    conn
  end

end
