defmodule AppsignalPhoenixExampleWeb.Plugs.ExamplePlug do
  import Plug.Conn

  def init(options), do: options

  def call(%{request_path: "/plug"} = plug, _options) do
    Appsignal.instrument("plug", fn ->
      plug
    end)
  end
end
