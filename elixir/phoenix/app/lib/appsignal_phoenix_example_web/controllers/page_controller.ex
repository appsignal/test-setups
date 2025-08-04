defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller
  use Appsignal.Instrumentation.Decorators

  def home(conn, _params) do
    render(conn, :home)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    text(conn, "That took forever!")
  end

  def error(conn, _params) do
    raise "Oops!"
  end

  @decorate transaction_event()
  def decorated(conn, _params) do
    render(conn, :home)
  end

  # Test function - should send data to AppSignal according to user report
  def test(conn, params) do
    var = Map.get(params, "var", "default test value")
    result = Appsignal.instrument("Elixir.Web.Controller.test/1", fn span -> 
      IO.puts(var)
      "Test completed with value: #{var}"
    end)
    text(conn, result)
  end

  # Search function - executes successfully but doesn't send data to AppSignal according to user report
  def search(conn, params) when is_map(params) do
    # Add current_scope to conn assigns for testing
    conn = assign(conn, :current_scope, "test_scope")
    
    Appsignal.instrument("Elixir.Web.Controller.search/2", fn span ->
      with {:ok, {query, search_opts}} <- SearchParams.parse(params) do
        pdps = ProductSearch.search(conn.assigns.current_scope, query, search_opts)
        render(conn, :search_results, pdps: pdps)
      end
    end)
  end
end
