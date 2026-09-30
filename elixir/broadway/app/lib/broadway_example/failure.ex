defmodule BroadwayExample.Failure do
  @moduledoc """
  Turns a failed `Broadway.Message`'s status into something short enough to log.

  A message that raised carries its whole stacktrace in `:status`, which is more
  than the logs need.
  """

  @doc """
  Describes a `Broadway.Message` status in a single line.
  """
  def describe(:ok), do: "ok"

  def describe({:failed, reason}), do: "failed: #{inspect(reason)}"

  def describe({_kind, %{__exception__: true} = exception, _stacktrace}),
    do: Exception.message(exception)

  def describe({kind, reason, _stacktrace}), do: "#{kind}: #{inspect(reason)}"
end
