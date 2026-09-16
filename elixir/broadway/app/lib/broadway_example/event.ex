defmodule BroadwayExample.Event do
  @moduledoc """
  The "source data" this pipeline consumes.

  In a real pipeline these would arrive from SQS, RabbitMQ, Kafka, and so on.
  Here `BroadwayExample.Producer` makes them up, so the demo has no external
  dependencies.
  """

  @customers ~w(acme globex initech umbrella hooli)
  @currency "EUR"

  @doc """
  Builds a random payment event.

  Pass `overrides` to force a specific scenario, for example
  `random(%{fail: true})` to make the processor raise on this message.
  """
  def random(overrides \\ %{}) do
    Map.merge(
      %{
        id: System.unique_integer([:positive, :monotonic]),
        customer: Enum.random(@customers),
        currency: @currency,
        amount_cents: Enum.random(100..250_000),
        queued_at: System.monotonic_time(:millisecond)
      },
      overrides
    )
  end

  @doc """
  Builds `count` random payment events.
  """
  def random_batch(count, overrides \\ %{}) when count > 0 do
    Enum.map(1..count, fn _ -> random(overrides) end)
  end
end
