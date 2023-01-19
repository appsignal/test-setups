defmodule AppsignalPhoenixExampleWeb.LiveComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <button phx-click="raise_exception" phx-target={@myself}>raise component error</button>
    """
  end

  def handle_event("raise_exception", _value, socket) do
    raise "Component exception!"

    {:noreply, socket}
  end
end
