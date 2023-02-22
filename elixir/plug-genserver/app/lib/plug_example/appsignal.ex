defmodule Appsignal.GenServer.Carrier do
  defstruct [:request]
end

defmodule Appsignal.GenServer do
  defmacro __using__(args) do
    quote do
      use Elixir.GenServer, unquote(args)
      alias Appsignal.GenServer

      def handle_call(%Appsignal.GenServer.Carrier{request: request}, from, state) do
        IO.puts("I'm in carrier handle_call!")
        span_name = Appsignal.GenServer.Utils.handle_name("call", __MODULE__, request)
        Appsignal.instrument(span_name, "call.genserver", fn span ->
          Appsignal.Span.set_namespace(span, "genserver")
          handle_call(request, from, state)
        end)
      end
    end
  end

  defdelegate abcast(nodes \\ [node() | Node.list()], name, request), to: Elixir.GenServer
  defdelegate cast(server, request), to: Elixir.GenServer
  defdelegate multi_call(nodes \\ [node() | Node.list()], name, request, timeout \\ :infinity), to: Elixir.GenServer
  defdelegate reply(client, reply), to: Elixir.GenServer
  defdelegate start(module, init_arg, options \\ []), to: Elixir.GenServer
  defdelegate start_link(module, init_arg, options \\ []), to: Elixir.GenServer
  defdelegate stop(server, reason \\ :normal, timeout \\ :infinity), to: Elixir.GenServer
  defdelegate whereis(server), to: Elixir.GenServer

  def call(server, request, timeout \\ 5000) do
    IO.puts("I'm in carrier call!")
    span_name = Appsignal.GenServer.Utils.invoke_name("call", server, request)
    Appsignal.instrument(span_name, "call.genserver", fn ->
      Elixir.GenServer.call(server, %Appsignal.GenServer.Carrier{request: request}, timeout)
    end)
  end
end

defmodule Appsignal.GenServer.Utils do
  def invoke_name(method, server, request) do
    "GenServer.#{method}(#{server_name(server)}, #{request_name(request)})"
  end

  def handle_name(method, server, request) do
    "#{server_name(server)}.#{method}(#{request_name(request)})"
  end

  defp request_name(request) when is_atom(request), do: inspect(request)

  defp request_name(request)
    when is_tuple(request)
    and tuple_size(request) > 1
    and is_atom(elem(request, 0)) do
    "{#{inspect(elem(request, 0))}, ...}"
  end

  defp request_name(request)
    when is_tuple(request)
    and tuple_size(request) == 1
    and is_atom(elem(request, 0)) do
    "{#{inspect(elem(request, 0))}}"
  end

  defp request_name(request) when is_struct(request), do: "%#{inspect(request.__struct__)}{...}"
  defp request_name(_request), do: "..."

  defp server_name(server) when is_pid(server), do: "#PID<...>"
  defp server_name(server) when is_port(server), do: "#Port<...>"
  defp server_name(server) when is_atom(server), do: inspect(server)
  defp server_name({:via, _module, _name} = server), do: inspect(server)
  defp server_name({:global, _term} = server), do: inspect(server)

  defp server_name(server)
    when is_tuple(server)
    and tuple_size(server) > 1 do
    "{#{inspect(elem(server, 0))}, ...}"
  end
  
  defp server_name(_server), do: "..."
end
