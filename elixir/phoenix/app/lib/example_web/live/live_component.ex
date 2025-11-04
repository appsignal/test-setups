defmodule ExampleWeb.LiveComponent do
  use ExampleWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, :brightness, 50)}
  end

  def render(assigns) do
    ~H"""
    <div class="component-container">
      <div class="hero">Hello LiveComponent!</div>

      <div class="light">
        <div class="bar" style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </div>
      </div>

      <button phx-click="down" phx-target={@myself}>
        Down
      </button>

      <button phx-click="up" phx-target={@myself}>
        Up
      </button>
    </div>
    """
  end

  def handle_event("down", _, socket) do
    IO.puts("LiveComponent handle_event down")
    brightness = socket.assigns.brightness - 10
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    IO.puts("LiveComponent handle_event up")
    brightness = socket.assigns.brightness + 10
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end
end
