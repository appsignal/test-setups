defmodule TestApp.PerformanceWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    IO.puts "PerformanceWorker run!"
    IO.inspect args

    :ok
  end
end
