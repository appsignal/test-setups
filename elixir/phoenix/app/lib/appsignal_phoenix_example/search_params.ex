defmodule SearchParams do
  @moduledoc """
  Mock module for parsing search parameters
  """

  def parse(params) when is_map(params) do
    # Simulate failure case when params contains "fail" 
    if Map.get(params, "fail") do
      {:error, :simulated_failure}
    else
      query = Map.get(params, "q", "")
      search_opts = %{
        limit: parse_integer(Map.get(params, "limit", "10")),
        offset: parse_integer(Map.get(params, "offset", "0"))
      }
      {:ok, {query, search_opts}}
    end
  end

  def parse(_), do: {:error, :invalid_params}

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> {:error, :invalid_integer}
    end
  end
  
  defp parse_integer(value) when is_integer(value), do: value
  defp parse_integer(_), do: {:error, :invalid_integer}
end