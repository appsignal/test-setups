defmodule BroadwayExample.Producer do
  @moduledoc """
  A hand-written GenStage producer, the first stage of the pipeline.

  Broadway does not start this module itself; it calls `init/1` on it and wraps
  it in its own producer stage. That means we only implement GenStage callbacks
  here, no `start_link/1`.

  A producer is demand driven: the processors downstream ask for N messages and
  `handle_demand/2` is expected to answer with *at most* N events. Anything we
  cannot satisfy right away has to be remembered, which is what `demand` in the
  state is for. Likewise, events that arrive when nobody is asking for them go
  into `queue` until demand shows up.
  """

  use GenStage

  @behaviour Broadway.Producer

  require Logger

  alias BroadwayExample.Stats

  @doc """
  Pushes events into a running pipeline's producer.

  `Broadway.push_messages/2` only works with `Broadway.DummyProducer`, so with a
  custom producer we look up the producer process by name and cast to it
  ourselves.
  """
  def push(events, pipeline \\ BroadwayExample.Pipeline) when is_list(events) do
    pipeline
    |> Broadway.producer_names()
    |> Enum.random()
    |> GenStage.cast({:push, events})
  end

  @impl GenStage
  def init(_opts) do
    {:producer, %{queue: :queue.new(), queue_size: 0, demand: 0}}
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    dispatch(%{state | demand: state.demand + incoming_demand})
  end

  @impl GenStage
  def handle_cast({:push, events}, state) do
    state |> enqueue(events) |> dispatch()
  end

  # Broadway drains the producer before shutting the pipeline down. Returning
  # the state unchanged is enough here: whatever is still queued is dropped,
  # because there is no source to hand it back to.
  @impl Broadway.Producer
  def prepare_for_draining(state) do
    Logger.info("Producer draining with #{state.queue_size} event(s) still queued")

    {:noreply, [], state}
  end

  defp enqueue(state, events) do
    queue = Enum.reduce(events, state.queue, &:queue.in/2)
    count = length(events)

    Stats.record(:produced, count)

    %{state | queue: queue, queue_size: state.queue_size + count}
  end

  defp dispatch(state) do
    to_send = min(state.demand, state.queue_size)
    {events, queue} = take(state.queue, to_send)

    state = %{
      state
      | queue: queue,
        queue_size: state.queue_size - to_send,
        demand: state.demand - to_send
    }

    Stats.gauge(:queue_size, state.queue_size)

    {:noreply, events, state}
  end

  defp take(queue, count) do
    Enum.map_reduce(1..count//1, queue, fn _, queue ->
      {{:value, event}, queue} = :queue.out(queue)
      {event, queue}
    end)
  end
end
