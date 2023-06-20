defmodule AppsignalPhoenixExampleWeb.PageController do
  use AppsignalPhoenixExampleWeb, :controller

  alias AppsignalPhoenixExample.Accounts
  alias AppsignalPhoenixExample.Accounts.User
  require Logger
  plug DemoPlug, "en"

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def slow(conn, _params) do
    :timer.sleep(3000)
    render(conn, "slow.html")
  end

  def error(_conn, _params) do
    raise "This is a Phoenix error!"
  end

  def backtrace_error(_conn, _params) do
    pid = self()
    port = Port.open({:spawn, "echo hello"}, [:binary])

    backtrace_error_inner(
      %{
        pid: pid,
        nil: nil,
        true: true,
        false: false,
        int: 123,
        float: 12.3,
        abc: "def",
        ghi: %{jkl: %{mno: "pqr", int: 123, float: 12.3}}
      },
      pid,
      port,
      nil,
      true,
      false,
      123,
      12.3,
      "abc"
    )
  end

  def backtrace_error_inner(%{abc: "def", ghi: %{jkl: %{other: v}}} = arg) do
  end

  def backtrace_error_inner(
        %{abc: "def", ghi: %{jkl: %{other: v}}} = arg,
        _pid,
        _port,
        _nil,
        _true,
        _false,
        _int,
        _float,
        _string
      ) do
  end

  def finch(conn, _params) do
    {:ok, response} = Finch.build(:get, "http://hex.pm") |> Finch.request(MyFinch)

    text(
      conn,
      "Performed an HTTP request using Finch: " <>
        "response status code is #{response.status}"
    )
  end
end
