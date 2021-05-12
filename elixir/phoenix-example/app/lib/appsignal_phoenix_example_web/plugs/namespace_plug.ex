defmodule NamespacePlug do
  import Plug.Conn
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    IO.puts("SET NAMESPACE")
    Appsignal.Span.set_namespace(Appsignal.Tracer.root_span(), "custom")

    conn
  end
end
