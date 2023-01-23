defmodule AppsignalPhoenixExampleWeb.LiveComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
    <button phx-click="raise_exception" phx-target={@myself}>raise component error</button>
    <button phx-click="create_user" phx-target={@myself}>raise component constraint error</button>
    </div>
    """
  end

  def handle_event("raise_exception", _value, socket) do
    raise "Component exception!"

    {:noreply, socket}
  end

  def handle_event("create_user", _value, socket) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, %AppsignalPhoenixExample.Accounts.User{name: "user", age: 10})
    |> AppsignalPhoenixExample.Repo.transaction()

    {:noreply, socket}
  end
end
