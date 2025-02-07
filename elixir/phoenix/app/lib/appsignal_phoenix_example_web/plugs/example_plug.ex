defmodule AppsignalPhoenixExampleWeb.Plugs.ExamplePlug do
  import Plug.Conn

  def init(options), do: options

  def call(%{request_path: "/plug"} = conn, _options) do
    Appsignal.instrument("plug", fn ->
      conn
    end)
  end

  def call(%{request_path: "/plug/error"} = conn, _options) do
    try do
      Appsignal.Span.set_sample_data(
	Appsignal.Tracer.root_span(),
	"tags",
	%{
	  user_id: 42
	}
      )

      raise "Error raised from ExamplePlug"
    catch
      kind, reason ->
	stack = __STACKTRACE__

	Appsignal.Tracer.root_span()
	|> Appsignal.Plug.handle_error(kind, reason, stack, conn)
	|> Appsignal.Span.set_name("ExamplePlug#call")
	|> Appsignal.Tracer.close_span()

        Appsignal.Tracer.ignore()
        :erlang.raise(kind, reason, stack)
      end

    conn
  end

  def call(conn, _options) do
    conn
  end
end
