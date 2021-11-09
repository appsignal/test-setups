{:ok, _} = Application.ensure_all_started(:appsignal)

defmodule Mix.Tasks.SequentialSpans do
  use Mix.Task

  def run(_args) do
    span =
      "tasks"
      |> Appsignal.Tracer.create_span()
      |> Appsignal.Span.set_name("Mix.Tasks.SequentialSpans.run/1")
      |> Appsignal.Span.set_attribute("appsignal:category", "root.sequential_spans")

    :timer.sleep(100)

    Appsignal.Tracer.close_span(span)

    child =
      "tasks"
      |> Appsignal.Tracer.create_span()
      |> Appsignal.Span.set_name("Mix.Tasks.SequentialSpans.run/1")
      |> Appsignal.Span.set_attribute("appsignal:category", "child.sequential_spans")

    :timer.sleep(100)

    Appsignal.Tracer.close_span(child)

    Appsignal.Nif.stop()
    :timer.sleep(30_000)
  end

  def do_stuff(i) when i == 0 do
    IO.puts("Done")
  end

  def do_stuff(i) do
    Appsignal.instrument("event.group", fn ->
      :timer.sleep(random_number = :rand.uniform(5))
    end)

    do_stuff(i - 1)
  end
end
