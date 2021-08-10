{:ok, _} = Application.ensure_all_started(:appsignal)

defmodule Mix.Tasks.SingleTask do
  use Mix.Task

  def run(_args) do
    Appsignal.instrument("MyTasks.Functions.run/1", "run/1.single_task", fn ->
      Appsignal.Span.set_namespace(Appsignal.Tracer.root_span(), "tasks")
      event_count = 1000
      Appsignal.Span.set_sample_data(
        Appsignal.Tracer.root_span,
        "params",
        %{
          events: event_count
        }
      )

      do_stuff(event_count)

      IO.puts "Sent a span with a #{event_count} events."
    end)
  end

  def do_stuff(i) when i == 0 do
    IO.puts "Done"
  end

  def do_stuff(i) do
    Appsignal.instrument("event.group", fn ->
      :timer.sleep(random_number = :rand.uniform(5))
    end)
    do_stuff(i - 1)
  end
end
