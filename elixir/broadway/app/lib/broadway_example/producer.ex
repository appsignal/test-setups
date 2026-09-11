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

  Events enter the queue from two places:

    * the `:tick` timer, which keeps a steady trickle of traffic going, and
    * `push/1`, which the web interface uses to inject a burst on demand.

  """

  use GenStage

  @behaviour Broadway.Producer

  require Logger

  alias BroadwayExample.{Event, Stats}

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
  def init(opts) do
    state = %{
      queue: :queue.new(),
      queue_size: 0,
      demand: 0,
      interval: Keyword.get(opts, :interval, 2_000),
      per_tick: Keyword.get(opts, :per_tick, 5)
    }

    schedule_tick(state)

    {:producer, state}
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    dispatch(%{state | demand: state.demand + incoming_demand})
  end

  @impl GenStage
  def handle_cast({:push, events}, state) do
    state |> enqueue(events) |> dispatch()
  end

  @impl GenStage
  def handle_info(:tick, state) do
    schedule_tick(state)

    state
    |> enqueue(Event.random_batch(state.per_tick))
    |> dispatch()
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

  # An interval of 0 turns the automatic trickle off, leaving only the events
  # pushed from the web interface.
  defp schedule_tick(%{interval: interval}) when interval > 0 do
    Process.send_after(self(), :tick, interval)
  end

  defp schedule_tick(_state), do: :ok
end
