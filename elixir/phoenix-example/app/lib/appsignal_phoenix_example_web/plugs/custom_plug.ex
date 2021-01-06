defmodule ChipWeb.CustomPlug do
  # use Appsignal.Plug
  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(%Conn{ path_info: [ "custom" ] } = conn, _opts) do
    Appsignal.instrument "ChipWeb.CustomPlug", fn ->
      Process.sleep(1000)
      conn
    end
  end

  def call(%Conn{} = conn, _opts) do
    conn
  end

end
