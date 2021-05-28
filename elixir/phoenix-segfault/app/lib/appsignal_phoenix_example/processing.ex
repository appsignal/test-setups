defmodule Processing do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(stack) do
    {:ok, stack}
  end

  def process(pid) do
    GenServer.cast(__MODULE__, {:process, pid})
  end

  def handle_cast({:process, pid}, _from, state) do
    span =
      "http_request"
      |> Appsignal.Tracer.create_span(Appsignal.Tracer.current_span(pid))
      |> Appsignal.Span.set_attribute("appsignal:category", "custom_category")
      |> Appsignal.Tracer.close_span()

    {:noreply, state}
  end
end
