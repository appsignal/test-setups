defmodule PlugOban.AddTask do
  use Oban.Worker, queue: :default

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"numbers" => numbers} = args}) do
    Logger.debug("Received add job with numbers: #{inspect(numbers)}")

    sum = Enum.sum(numbers)
    Logger.debug("Added up numbers to: #{inspect(sum)}")

    Process.sleep(sum)
    Logger.debug("Slept for #{inspect(sum)} milliseconds")

    if Map.get(args, "fail") do
      Logger.debug("Task failed!")
      raise PlugOban.TaskError
    end

    Logger.debug("Task completed!")
    :ok
  end
end
