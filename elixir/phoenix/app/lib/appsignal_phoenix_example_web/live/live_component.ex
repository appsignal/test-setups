defmodule AppsignalPhoenixExampleWeb.LiveComponent do
  use AppsignalPhoenixExampleWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="hero">Hello LiveComponent!</div>
    """
  end
end
