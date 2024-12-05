defmodule AppsignalPhoenixExampleWeb.DemoLive do
  use AppsignalPhoenixExampleWeb, :live_view

  def render(assigns) do
    ~H"""
    Hello LiveView!

    <.live_component module={AppsignalPhoenixExampleWeb.LiveComponent} id="component" />
    """
  end
end
