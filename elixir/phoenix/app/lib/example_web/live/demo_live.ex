defmodule ExampleWeb.DemoLive do
  use ExampleWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :brightness, 50)}
  end

  def handle_params(unsigned_params, uri, socket) do
    IO.puts("handle_params event")
    IO.inspect([unsigned_params, uri, socket])
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>LiveView test light</h1>

    <div class="light">
      <div class="bar" style={"width: #{@brightness}%"}>
        <%= @brightness %>%
      </div>
    </div>

    <button phx-click="down">
      Down
    </button>

    <button phx-click="up">
      Up
    </button>

    <hr />

    <.live_component module={ExampleWeb.LiveComponent} id="component" />
    """
  end

  def handle_event("down", _, socket) do
    IO.puts("LiveView handle_event down")
    brightness = socket.assigns.brightness - 10
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    IO.puts("LiveView handle_event up")
    brightness = socket.assigns.brightness + 10
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end
end
