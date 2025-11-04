defmodule ExampleWeb.LiveComponent do
  use ExampleWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="hero">Hello LiveComponent!</div>
    """
  end
end
