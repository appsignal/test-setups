defmodule PlugOban.AverageTask do
  use Oban.Worker, queue: :default

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"numbers" => numbers} = args}) do
    Logger.debug("Received average job with numbers: #{inspect(numbers)}")

    average = ceil(Enum.sum(numbers) / length(numbers))
    Logger.debug("Averaged numbers to: #{inspect(average)}")

    Process.sleep(average)
    Logger.debug("Slept for #{inspect(average)} milliseconds")

    if Map.get(args, "fail") do
      Logger.debug("Task failed!")
      raise PlugOban.TaskError
    end

    Logger.debug("Task completed!")
    :ok
  end
end
