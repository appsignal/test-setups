defmodule DemoPlug do
  import Plug.Conn
  require Logger

  @locales ["en", "fr", "de"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    Logger.info("Running call in DemoPlug for locale #{loc}")

    Appsignal.Span.set_namespace(Appsignal.Tracer.root_span(), "locale")

    Appsignal.instrument(fn span ->
      span
      |> Appsignal.Span.set_attribute("appsignal:category", "locale") # creates a sub event in event timeline
      |> Appsignal.Span.set_name("Locales.Instrument") # Events heading

      # Sample data can only be set on the root span and not on the child span
      Appsignal.Span.set_sample_data(Appsignal.Tracer.root_span, "custom_data", %{resolution: %{
        "current_user_permissions" => "resolution.context.current_user_permissions",
        "raw_query" => "resolution.context.conn.params",
        "graphql_args" => "inspect"
      }})
    end)
    assign(conn, :locale, loc)
  end

  def call(conn, default) do
    assign(conn, :locale, default)
  end
end
