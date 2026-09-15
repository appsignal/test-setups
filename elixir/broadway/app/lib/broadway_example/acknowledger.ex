defmodule BroadwayExample.Acknowledger do
  @moduledoc """
  Tells the source that a message is done with.

  Every Broadway message carries an acknowledger. Broadway calls `ack/3` once
  per producer, per batch, with the messages that succeeded and the ones that
  failed, so a real acknowledger would delete the successful messages from the
  queue and requeue (or dead-letter) the failed ones.

  Our source is an in-memory queue with nothing to ack against, so this one only
  records what happened.
  """

  @behaviour Broadway.Acknowledger

  require Logger

  alias BroadwayExample.{Failure, Stats}

  @doc """
  Returns the acknowledger tuple to put on a `Broadway.Message`.
  """
  @spec init() :: Broadway.Message.acknowledger()
  def init, do: {__MODULE__, :payments, %{}}

  @impl Broadway.Acknowledger
  def ack(:payments, successful, failed) do
    Stats.record(:acked, length(successful))
    Stats.record(:failed, length(failed))

    if failed != [] do
      reasons = Enum.map_join(failed, ", ", &Failure.describe(&1.status))

      Logger.warning(
        "Acking #{length(successful)} successful and #{length(failed)} failed " <>
          "message(s): #{reasons}"
      )
    end

    :ok
  end
end
