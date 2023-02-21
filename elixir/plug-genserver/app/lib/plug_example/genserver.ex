defmodule PlugExample.GenServer do
  use GenServer

  # Client
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def ping() do
    GenServer.call(__MODULE__, :ping)
  end

  # Server (callbacks)
  @impl true
  def init(_init_arg) do
    {:ok, nil}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    IO.puts(":ping handle_call was called!")
    # Meditate on it for a bit, so the resulting sample is >1ms
    Process.sleep(10)
    {:reply, :pong, state}
  end
end
