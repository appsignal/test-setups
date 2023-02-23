defmodule PlugOban.AddTask do
  use Oban.Worker, queue: :default

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"numbers" => numbers} = args}) do
    Appsignal.Logger.debug("app", "Received add job with numbers: #{inspect(numbers)}")

    Logger.debug("Received add job with numbers: #{inspect(numbers)}")

    sum = Enum.sum(numbers)
    Appsignal.Logger.debug("app", "Added up numbers to: #{inspect(sum)}")
    Logger.debug("Added up numbers to: #{inspect(sum)}")

    Process.sleep(sum)
    Appsignal.Logger.debug("app", "Slept for #{inspect(sum)} milliseconds")
    Logger.debug("Slept for #{inspect(sum)} milliseconds")

    if Map.get(args, "fail") do
      Appsignal.Logger.debug("app", "Task failed!")
      Logger.debug("Task failed!")
      raise PlugOban.TaskError
    end
    Appsignal.Logger.debug("app", "Task completed!")
    Logger.debug("Task completed!")
    :ok
  end
end
