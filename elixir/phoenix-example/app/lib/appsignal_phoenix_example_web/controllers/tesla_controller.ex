defmodule TeslaPathParamsExample do
  use Tesla, only: [:get]

  plug Tesla.Middleware.Telemetry
  plug Tesla.Middleware.PathParams
  plug Tesla.Middleware.BaseUrl, "https://hex.pm"

  def hex_package(name) do
    get("/packages/:package", opts: [path_params: [package: name]])
  end
end

defmodule TeslaVanillaExample do
  use Tesla, only: [:get]

  plug Tesla.Middleware.Telemetry

  def hex_package(name) do
    get("https://hex.pm/packages/#{name}")
  end
end

defmodule TeslaWithoutUseExample do
  # no `use Tesla` here!
  # see `Runtime middleware` in the Tesla documentation:
  # https://hexdocs.pm/tesla/readme.html#runtime-middleware

  def hex_package(client, name) do
    Tesla.get(client, "/#{name}")
  end

  def client do
    # This uses BaseUrl but not PathParams, so the span name should be
    # the full base URL, without the interpolated package name.
    middleware = [
      Tesla.Middleware.Telemetry,
      {Tesla.Middleware.BaseUrl, "https://hex.pm/packages"},
    ]

    Tesla.client(middleware)
  end
end

defmodule AppsignalPhoenixExampleWeb.TeslaController do
  use AppsignalPhoenixExampleWeb, :controller

  def pathparams(conn, _params) do
    {:ok, response} = TeslaPathParamsExample.hex_package("appsignal")
    message = "Performed an HTTP request using Tesla PathParams: " <>
      "response status code is #{response.status}"

    text(conn, message)
  end

  def vanilla(conn, _params) do
    {:ok, response} = TeslaVanillaExample.hex_package("appsignal_phoenix")
    message = "Performed an HTTP request using Tesla Vanilla: " <>
      "response status code is #{response.status}"

    text(conn, message)
  end

  def withoutuse(conn, _params) do
    client = TeslaWithoutUseExample.client()
    {:ok, response} = TeslaWithoutUseExample.hex_package(client, "appsignal_plug")
    message = "Performed an HTTP request using Tesla WithoutUse: " <>
      "response status code is #{response.status}"

    text(conn, message)
  end
end
