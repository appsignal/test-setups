defmodule ExampleWeb.PageController do
  use ExampleWeb, :controller
  use Appsignal.Instrumentation.Decorators

  def home(conn, _params) do
  Appsignal.Logger.info(
      "invoice_helper",
      "Generated invoice PLAINTEXT"
  )
  Appsignal.Logger.info(
      "invoice_helper",
      "Generated invoice invoice_id=A145 for customer LOGFMT customer_id=123"
  )
  Appsignal.Logger.info(
      "invoice_helper",
      ~s({"message": "Generated invoice for customer JSON", "invoice_id": "A145", "customer_id": "123"})
  )
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

  def httpoison(conn, _params) do
    case Appsignal.HTTPoison.get("https://api.github.com") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        text(conn, "GitHub API Response: #{String.slice(body, 0, 200)}...")
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        text(conn, "GitHub API returned status: #{status_code}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        text(conn, "Error calling GitHub API: #{inspect(reason)}")
    end
  end

  def httpoison_client(conn, _params) do
    text(conn, [
      ExampleWeb.CoolHTTPoisonClient.perform_good_request(),
      ExampleWeb.CoolHTTPoisonClient.perform_bad_request(),
      ExampleWeb.CoolHTTPoisonClient.perform_error_request()
    ] |> Enum.join("\n\n"))
  end
end

defmodule ExampleWeb.CoolHTTPoisonClient do
  use Appsignal.HTTPoison.Base

  def perform_good_request do
    get("https://api.github.com") |> handle_response()
  end

  def perform_bad_request do
    get("https://api.github.com/does_not_exist") |> handle_response()
  end

  def perform_error_request do
    get("http://example.invalid") |> handle_response()
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    "200 OK Body: #{String.slice(body, 0, 200)}..."
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: status_code}}) do
    "Status: #{status_code}"
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    "Error: #{inspect(reason)}"
  end
end
