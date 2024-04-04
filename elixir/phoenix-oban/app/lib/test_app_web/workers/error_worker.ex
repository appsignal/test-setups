defmodule TestApp.ErrorWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    IO.puts "ErrorWorker run!"
    IO.inspect args
    raise "This is an error from a job!"

    :ok
  end
end
