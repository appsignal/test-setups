defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User
  require Logger
  plug DemoPlug, "en"

  def index(conn, _params) do
    users = Accounts.list_users()
    slow()
    render(conn, "index.html", users: users)
  end

  defp slow do
    Appsignal.instrument("slow", fn ->
      :timer.sleep(1000)
      Logger.info("CURRENT_SPAN_12")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_13")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_14")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_15")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_16")
      Logger.info( Appsignal.Tracer.current_span())
    end)

    Appsignal.instrument("slow_2", fn ->
      :timer.sleep(1000)
      Logger.info("CURRENT_SPAN_22")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_23")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_24")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_25")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_26")
      Logger.info( Appsignal.Tracer.current_span())
    end)

    Appsignal.instrument("slow_3", fn ->
      :timer.sleep(1000)
      Logger.info("CURRENT_SPAN_32")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_33")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_34")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_35")
      Logger.info( Appsignal.Tracer.current_span())

      Logger.info("CURRENT_SPAN_36")
      Logger.info( Appsignal.Tracer.current_span())
    end)
  end
end
