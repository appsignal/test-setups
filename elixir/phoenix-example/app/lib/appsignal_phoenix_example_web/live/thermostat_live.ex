defmodule AppsignalPhoenixExampleWeb.ThermostatLive do
  use Phoenix.LiveView

  def render(assigns) do
    AppsignalPhoenixExampleWeb.ThermostatView.render("index.html", assigns)
  end

  def mount(_params, _session, socket) do
    Process.send_after(self(), :update, 30000)

    {:ok, assign(socket, temperature: 19.0)}
  end

  def handle_event("inc_temperature", _value, socket) do
    {:noreply, assign(socket, :temperature, socket.assigns.temperature + 1)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, temperature: 18.0)}
  end
end
