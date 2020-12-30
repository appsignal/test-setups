defmodule DemoPlug do
  import Plug.Conn
  require Logger

  @locales ["en", "fr", "de"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    Logger.info("inside the cal and locate is: #{loc}")

    Appsignal.instrument(fn span ->
      span
      |> Appsignal.Span.set_namespace("graphql")
      |> Appsignal.Span.set_name("Locales.Instrument")
      |> Appsignal.Span.set_attribute("appsignal:category", "locale")
      |> Appsignal.Span.set_sample_data("resolution", %{
        "current_user_permissions" => "resolution.context.current_user_permissions",
        "raw_query" => "resolution.context.conn.params",
        "graphql_args" => "inspect"
      })

    end)
    assign(conn, :locale, loc)
  end

  def call(conn, default) do
    assign(conn, :locale, default)
  end
end
