defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller
  use Appsignal.Instrumentation.Decorators

  def home(conn, _params) do
    render(conn, :home)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    text(conn, "That took forever!")
  end

  def error(conn, _params) do
    raise "Oops!"
  end

  def instrumented(conn, _params) do
    Appsignal.instrument("instrumented", fn ->
      render(conn, :home)
    end)
  end

  @decorate transaction_event()
  def decorated(conn, _params) do
    render(conn, :home)
  end
end
