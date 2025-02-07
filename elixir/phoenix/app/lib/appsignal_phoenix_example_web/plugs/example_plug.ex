defmodule AppsignalPhoenixExampleWeb.Plugs.ExamplePlug do
  import Plug.Conn

  def init(options), do: options

  def call(%{request_path: "/plug"} = plug, _options) do
    Appsignal.instrument("plug", fn ->
      plug
    end)
  end

  def call(%{request_path: "/plug/error"} = plug, _options) do
    try do
      raise "Error raised from ExamplePlug"
    catch
      kind, reason ->
	Appsignal.set_error(kind, reason, __STACKTRACE__)
    end

    plug
  end
end
