defmodule BroadwayExample.Application do
  @moduledoc false

  use Application

  require Logger

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  # @appsignal Application.compile_env(:appsignal, :appsignal, Appsignal)

  @impl Application
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4000")

    children = [
      BroadwayExample.Stats,
      BroadwayExample.Pipeline,
      {Plug.Cowboy, scheme: :http, plug: BroadwayExample.Router, options: [port: port]}
    ]

    Logger.info("Listening on http://localhost:#{port}")

    attach()

    Supervisor.start_link(children, strategy: :one_for_one, name: BroadwayExample.Supervisor)
  end

  defp attach() do
    handlers = %{
      [:broadway, :topology, :init] => &__MODULE__.log_init/4,
      [:broadway, :processor, :message, :start] => &__MODULE__.log_it/4,
      [:broadway, :processor, :message, :stop] => &__MODULE__.log_it/4,
      [:broadway, :processor, :message, :exception] => &__MODULE__.log_exception/4
    }

    for {event, fun} <- handlers do
      detach = :telemetry.detach({__MODULE__, event})
      attach = :telemetry.attach({__MODULE__, event}, event, fun, :ok)

      case {detach, attach} do
        {:ok, :ok} ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Oban reattached to #{inspect(event)}")

          :ok

        {{:error, :not_found}, :ok} ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Oban attached to #{inspect(event)}")

          :ok

        {_, {:error, _} = error} ->
          Logger.warning("Appsignal.Oban not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def log_init(event, measurements, metadata, config) do
    # IO.inspect(event, label: "event")
    # IO.inspect(measurements, label: "measurements")
    # IO.inspect(metadata, label: "metadata")
    # IO.inspect(config, label: "config")

    do_log_init(measurements, metadata)
  end

  defp do_log_init(
         %{system_time: system_time},
         %{supervisor_pid: supervisor_pid, config: config}
       ) do
    span = @tracer.create_span("broadway")

    span
    |> @span.set_attribute("appsignal:category", "topology_init.broadway")
    |> @span.set_attribute("system_time", system_time)
    |> @span.set_attribute("supervisor_pid", supervisor_pid)
    |> @span.set_attribute("config", config)
  end

  def log_it(event, measurements, metadata, config) do
    # IO.inspect(event, label: "event")
    # IO.inspect(measurements, label: "measurements")
    # IO.inspect(metadata, label: "metadata")
    # IO.inspect(config, label: "config")

    do_log_it(metadata)
  end

  defp do_log_it(%{
         index: index,
         message:
           %Broadway.Message{
             data: _event_data,
             metadata: %{},
             acknowledger: {BroadwayExample.Acknowledger, :payments, %{}},
             batcher: _batcher,
             batch_key: _batch_key,
             batch_mode: _batch_mode,
             status: _status
           } = message,
         name: name,
         context: context,
         telemetry_span_context: telemetry_span_context,
         producer: producer,
         topology_name: topology_name,
         processor_key: processor_key
       }) do
    span = @tracer.create_span("broadway")

    span
    |> @span.set_attribute("appsignal:category", "processor_message.broadway")
    |> @span.set_name(to_string(name))
    |> @span.set_sample_data("message", to_string(inspect(message)))
    |> @span.set_attribute("index", index)
    |> @span.set_attribute("processor_key", processor_key)
    |> @span.set_attribute("topology_name", topology_name)
    |> @span.set_attribute("telemetry_span_context", telemetry_span_context)
    |> @span.set_attribute("producer", producer)
  end

  def log_exception(event, measurements, metadata, config) do
    IO.puts("Log exception")
    # IO.inspect(event, label: "event")
    # IO.inspect(measurements, label: "measurements")
    # IO.inspect(metadata, label: "metadata")
    # IO.inspect(config, label: "config")

    do_log_exception(metadata)
  end

  defp do_log_exception(%{
         index: index,
         message: %Broadway.Message{
           data:
             %{
               id: _id,
               fail: _fail,
               currency: _currency,
               amount_cents: _amount_cents,
               customer: _customer,
               queued_at: _queued_at
             } = message,
           metadata: %{},
           acknowledger: {BroadwayExample.Acknowledger, :payments, %{}},
           batcher: :default,
           batch_key: :default,
           batch_mode: :bulk,
           status: :ok
         },
         name: name,
         reason: reason,
         context: :context_not_set,
         stacktrace: stacktrace,
         kind: kind,
         telemetry_span_context: telemetry_span_context,
         producer: producer,
         topology_name: topology_name,
         processor_key: processor_key
       }) do
    span = @tracer.create_span("broadway")

    span
    |> @span.set_attribute("appsignal:category", "processor_message_exception.broadway")
    |> @span.set_name(to_string(name))
    |> @span.set_sample_data("message", to_string(inspect(message)))
    |> @span.set_attribute("index", index)
    |> @span.set_attribute("processor_key", processor_key)
    |> @span.set_attribute("topology_name", topology_name)
    |> @span.set_attribute("telemetry_span_context", telemetry_span_context)
    |> @span.set_attribute("producer", producer)
    |> @span.set_attribute("kind", kind)
    |> @span.set_attribute("reason", to_string(inspect(reason)))
    |> @span.set_attribute("stacktrace", to_string(inspect(stacktrace)))
    |> IO.inspect(label: "log exception")
  end
end
