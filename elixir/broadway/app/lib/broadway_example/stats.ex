defmodule BroadwayExample.Stats do
  @moduledoc """
  Counters behind the status page, so you can see the pipeline moving without
  reading the logs.
  """

  use GenServer

  @table __MODULE__
  @counters [
    :produced,
    :processed,
    :batched_default,
    :batched_suspicious,
    :acked,
    :failed
  ]
  @gauges [:queue_size]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Adds `count` to a counter.
  """
  def record(_key, 0), do: :ok

  def record(key, count) when key in @counters do
    :ets.update_counter(@table, key, count)

    :ok
  end

  @doc """
  Sets a gauge.
  """
  def gauge(key, value) when key in @gauges do
    :ets.insert(@table, {key, value})

    :ok
  end

  @doc """
  Returns every counter and gauge as a map.
  """
  def all do
    Map.new(:ets.tab2list(@table))
  end

  @impl GenServer
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table, write_concurrency: true])

    for key <- @counters ++ @gauges, do: :ets.insert(@table, {key, 0})

    {:ok, :ok}
  end
end
