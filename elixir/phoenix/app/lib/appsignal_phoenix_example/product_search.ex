defmodule ProductSearch do
  @moduledoc """
  Mock module for product search functionality
  """

  def search(_scope, query, _search_opts) do
    # Mock search results
    [
      %{id: 1, name: "Product matching '#{query}'", price: 19.99},
      %{id: 2, name: "Another product for '#{query}'", price: 29.99}
    ]
  end
end