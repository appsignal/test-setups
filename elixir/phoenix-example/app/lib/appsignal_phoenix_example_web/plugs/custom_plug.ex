defmodule ChipWeb.CustomPlug do

  alias Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _) do
    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span,
      "tags",
      %{
        locale: "en",
        user_id: "1",
        stripe_customer_id: "cus_abc",
        locale: "en"
      }
    )
    conn
  end

end
