defmodule AppsignalPhoenixExampleWeb.ThermostatLive do
  # In Phoenix v1.6+ apps, the line below should be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    Current temperature: <%= @temperature %>
    <br>
    <button phx-click="dec_temperature">-</button>
    <button phx-click="inc_temperature">+</button>
    <button phx-click="raise_exception">raise exception</button>
    <button phx-click="create_user">raise constraint error</button>
    <.live_component module={AppsignalPhoenixExampleWeb.LiveComponent} id="component" />
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :temperature, 20.0)}
  end

  def handle_event("dec_temperature", _value, socket) do
    {:noreply, assign(socket, :temperature, socket.assigns.temperature - 1.0)}
  end

  def handle_event("inc_temperature", _value, socket) do
    {:noreply, assign(socket, :temperature, socket.assigns.temperature + 1.0)}
  end

  def handle_event("raise_exception", _value, socket) do
    raise "Exception!"

    {:noreply, socket}
  end

  def handle_event("create_user", _value, socket) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, %AppsignalPhoenixExample.Accounts.User{name: "user", age: 10})
    |> AppsignalPhoenixExample.Repo.transaction()

    {:noreply, socket}
  end
end
