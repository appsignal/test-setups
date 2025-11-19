defmodule TestApp.TimeoutWorker do
  use Oban.Worker
  def timeout(_job), do: :timer.seconds(1)

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    IO.puts "TimeoutWorker running!"
    :timer.sleep(3000)
    IO.puts "TimeoutWorker ran!"
    IO.inspect args

    :ok
  end
end
