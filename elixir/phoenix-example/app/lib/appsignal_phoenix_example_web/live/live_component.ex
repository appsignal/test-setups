defmodule AppsignalPhoenixExampleWeb.LiveComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <button phx-click="raise_exception">raise component exception</button>
    """
  end
end
