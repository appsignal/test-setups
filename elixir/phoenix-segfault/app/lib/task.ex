defmodule Async.Task do
  @moduledoc """
  Wrapper around Task to provide a more complete stacktrace on function execution failure and
  improved telemetry via appsignal instrumentation
  """

  @behaviour Async.Impl

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @impl Async.Impl
  @spec child_spec(term()) :: Supervisor.child_spec()
  def child_spec(_arg), do: Task.Supervisor.child_spec(name: __MODULE__)

  @impl Async.Impl
  @spec start(function(), String.t()) :: {:ok, pid()}
  def start(func, label) when is_function(func, 0) do
    parent_pid = self()
    {:current_stacktrace, stacktrace} = Process.info(parent_pid, :current_stacktrace)

    Task.Supervisor.start_child(__MODULE__, fn ->
      try do
        measure_func(func, label, parent_pid)
      rescue
        error -> reraise(Exception.format(:error, error, __STACKTRACE__), stacktrace)
      end
    end)
  end

  @impl Async.Impl
  @spec async(function(), String.t()) :: Task.t()
  def async(func, label) when is_function(func, 0) do
    parent_pid = self()
    {:current_stacktrace, stacktrace} = Process.info(parent_pid, :current_stacktrace)

    Task.async(fn ->
      try do
        measure_func(func, label, parent_pid)
      rescue
        error -> reraise(Exception.format(:error, error, __STACKTRACE__), stacktrace)
      end
    end)
  end

  @impl Async.Impl
  @spec await(Task.t(), integer()) :: term() | no_return()
  def await(%Task{} = task, timeout) do
    Task.await(task, timeout)
  end

  @impl Async.Impl
  @spec stream(Enumerable.t(), (term() -> term()), String.t(), keyword()) :: Enumerable.t()
  def stream(enum, func, label, opts) do
    parent_pid = self()
    {:current_stacktrace, stacktrace} = Process.info(parent_pid, :current_stacktrace)

    default_opts = [timeout: 15_000]
    combined_opts = Keyword.merge(default_opts, opts)

    Task.async_stream(
      enum,
      fn elem ->
        try do
          measure_func(fn -> func.(elem) end, label, parent_pid)
        rescue
          error -> reraise(Exception.format(:error, error, __STACKTRACE__), stacktrace)
        end
      end,
      combined_opts
    )
  end

  defp measure_func(func, label, pid) do
    case @tracer.current_span(pid) do
      nil ->
        func.()

      current_span ->
        start_time = :os.system_time()

        {duration, result} = :timer.tc(func)

        "async"
        |> @tracer.create_span(current_span, start_time: start_time)
        |> @span.set_name(label)
        |> @span.set_attribute("appsignal:category", inspect(__MODULE__))
        |> @tracer.close_span(
          end_time: start_time + System.convert_time_unit(duration, :microsecond, :native)
        )

        result
    end
  end
end
