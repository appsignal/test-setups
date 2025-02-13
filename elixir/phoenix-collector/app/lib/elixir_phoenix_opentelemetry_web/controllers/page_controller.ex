defmodule ElixirPhoenixOpentelemetryWeb.PageController do
  use ElixirPhoenixOpentelemetryWeb, :controller

  require OpenTelemetry.Tracer

  def index(conn, _params) do
    {:ok, request_parameters} =
      JSON.encode(%{
        password: "super secret",
        email: "test@example.com",
        cvv: 123,
        test_param: "test value",
        nested: %{
          password: "super secret nested",
          test_param: "test value"
        }
      })

    {:ok, request_session_data} =
      JSON.encode(%{
        token: "super secret",
        user_id: 123,
        test_param: "test value",
        nested: %{
          token: "super secret nested",
          test_param: "test value"
        }
      })

    {:ok, function_parameters} =
      JSON.encode(%{
        hash: "super secret",
        salt: "shoppai",
        test_param: "test value",
        nested: %{
          hash: "super secret nested",
          test_param: "test value"
        }
      })

    OpenTelemetry.Tracer.set_attributes([
      {:"appsignal.request.parameters", request_parameters},
      {:"appsignal.request.session_data", request_session_data},
      {:"appsignal.function.parameters", function_parameters}
    ])

    render(conn, "index.html")
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    render(conn, "slow.html")
  end

  def error(_conn, _params) do
    raise "This is a Phoenix error!"
  end
end
