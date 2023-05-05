defmodule CustomPlug do
  def init(_params) do
  end

  def call(conn, _params) do
    dbg(Appsignal.Tracer.root_span)
    Appsignal.Span.set_sample_data(Appsignal.Tracer.root_span, "tags", %{tags: "yes"})
    conn
  end
end
