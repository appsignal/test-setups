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

  def custom_instrumentation(conn, _params) do
    Appsignal.Span.set_namespace(Appsignal.Tracer.root_span(), "custom")

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "tags",
      %{
        tag1: "value1",
        tag2: 123
      }
    )

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "params",
      %{
        query: "something to search for",
        language: "en_US"
      }
    )

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "session_data",
      %{
        session: %{
          user_id: "123",
          menu_collapsed: true
        }
      }
    )

    Appsignal.Span.set_sample_data(
      Appsignal.Tracer.root_span(),
      "custom_data",
      %{
        custom: %{
          data: "test",
          more: "data"
        }
      }
    )

    Appsignal.instrument("event.custom", fn ->
      :timer.sleep(100)

      Appsignal.instrument("nested.custom", fn ->
        :timer.sleep(100)
      end)

      Appsignal.instrument("Build complicated SQL query", "prepare_query.sql", fn span ->
        Appsignal.Span.set_sql(span, "SOME complicate SQL query")
      end)
    end)

    text(
      conn,
      "Tracked some code with custom instrumentation"
    )
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
