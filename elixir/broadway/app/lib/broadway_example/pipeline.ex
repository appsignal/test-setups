defmodule BroadwayExample.Pipeline do
  @moduledoc """
  The Broadway pipeline itself.

  The topology this sets up:

      producer (1)
         |
      processors (2)   handle_message/3, once per message
         |
      :default         batcher, grouping messages into batches
         |
      batch procs      handle_batch/4, once per batch
  """

  use Broadway

  require Logger

  alias Broadway.Message
  alias BroadwayExample.{Acknowledger, Failure, Stats}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayExample.Producer, []},
        # Our producer emits plain maps, not %Broadway.Message{} structs, so a
        # transformer wraps them. Producers for SQS, RabbitMQ and friends emit
        # messages themselves and need no transformer.
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        # Two processor processes, each asking for at most 5 messages at a time.
        default: [concurrency: 2, max_demand: 5]
      ],
      batchers: [
        # Flush as soon as 10 messages pile up, or after 2 seconds, whichever
        # comes first.
        default: [concurrency: 1, batch_size: 10, batch_timeout: 2_000]
      ]
    )
  end

  @doc """
  Turns an event emitted by the producer into a `Broadway.Message`.
  """
  def transform(event, _opts) do
    %Message{data: event, acknowledger: Acknowledger.init()}
  end

  @impl Broadway
  def handle_message(:default, %Message{data: event} = message, _context) do
    Stats.record(:processed, 1)

    if event[:slow], do: Process.sleep(Enum.random(500..1_500))

    if event[:fail] do
      raise BroadwayExample.ProcessingError, id: event.id
    end

    enriched = Map.put(event, :amount, event.amount_cents / 100)

    Logger.debug(
      "Processed payment #{enriched.id}: #{format(enriched.amount)} #{enriched.currency} " <>
        "for #{enriched.customer}"
    )

    message
    |> Message.put_data(enriched)
    |> Message.put_batcher(:default)
    # The batch key splits one batcher's messages into separate batches. Every
    # payment is in EUR, so there is only ever one key in practice; it is kept
    # to show where that split would happen.
    |> Message.put_batch_key(enriched.currency)
  end

  @impl Broadway
  def handle_batch(:default, messages, batch_info, _context) do
    total = messages |> Enum.map(& &1.data.amount) |> Enum.sum()

    Stats.record(:batched, length(messages))

    Logger.info(
      "Settling #{length(messages)} payment(s) worth #{format(total)} #{batch_info.batch_key}"
    )

    # Pretend to write the batch somewhere. Doing the work per batch rather than
    # per message is the whole point of a batcher: one round trip for ten
    # messages instead of ten round trips.
    Process.sleep(100)

    messages
  end

  # Called for every message that failed in a processor or a batch processor,
  # just before it is acked as failed. This is where a real pipeline would
  # decide to retry or dead-letter.
  @impl Broadway
  def handle_failed(messages, _context) do
    Enum.each(messages, fn message ->
      Logger.error(
        "Dead-lettering payment #{message.data.id}: #{Failure.describe(message.status)}"
      )
    end)

    messages
  end

  defp format(amount), do: :erlang.float_to_binary(amount, decimals: 2)
end
