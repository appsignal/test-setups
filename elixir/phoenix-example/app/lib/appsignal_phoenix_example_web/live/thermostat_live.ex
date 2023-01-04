defmodule AppsignalPhoenixExampleWeb.ThermostatLive do
  # In Phoenix v1.6+ apps, the line below should be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    Current temperature: <%= @temperature %>
    <br>
    <button phx-click="dec_temperature">-</button>
    <button phx-click="inc_temperature">+</button>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :temperature, 20.0)}
  end

  def handle_event("dec_temperature", _value, socket) do
    {:noreply, assign(socket, :temperature, socket.assigns.temperature - 1.0)}
  end

  def handle_event("inc_temperature", _value, socket) do
    temperature = socket.assigns.temperature

    if temperature > 21.0 do
      raise "Exception!"
    end

    {:noreply, assign(socket, :temperature, temperature + 1.0)}
  end
end
