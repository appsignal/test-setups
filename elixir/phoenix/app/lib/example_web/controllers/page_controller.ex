defmodule ExampleWeb.PageController do
  use ExampleWeb, :controller
  use Appsignal.Instrumentation.Decorators

  def home(conn, _params) do
  Appsignal.Logger.info(
      "invoice_helper",
      "Generated invoice PLAINTEXT"
  )
  Appsignal.Logger.info(
      "invoice_helper",
      "Generated invoice invoice_id=A145 for customer LOGFMT customer_id=123"
  )
  Appsignal.Logger.info(
      "invoice_helper",
      ~s({"message": "Generated invoice for customer JSON", "invoice_id": "A145", "customer_id": "123"})
  )
    render(conn, :home)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    text(conn, "That took forever!")
  end

  def error(conn, _params) do
    raise "Oops!"
  end

  @decorate transaction_event()
  def decorated(conn, _params) do
    render(conn, :home)
  end
end
