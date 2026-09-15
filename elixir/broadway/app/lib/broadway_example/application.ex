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
      [:broadway, :topology, :init] => &__MODULE__.broadway_topology_init/4,
      [:broadway, :processor, :start] => &__MODULE__.broadway_processor_start/4,
      [:broadway, :batch_processor, :start] => &__MODULE__.broadway_batch_processor_start/4,
      [:broadway, :processor, :message, :start] => &__MODULE__.broadway_message_start/4,
      [:broadway, :processor, :message, :exception] => &__MODULE__.log_exception/4,
      [:broadway, :processor, :message, :stop] => &__MODULE__.broadway_message_stop/4,
      [:broadway, :batch_processor, :stop] => &__MODULE__.broadway_batch_processor_stop/4,
      [:broadway, :processor, :stop] => &__MODULE__.broadway_processor_stop/4
    }

    for {event, fun} <- handlers do
      detach = :telemetry.detach({__MODULE__, event})
      attach = :telemetry.attach({__MODULE__, event}, event, fun, :ok)

      case {detach, attach} do
        {:ok, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug(
              "Appsignal.Broadway reattached to #{inspect(event)}"
            )

          :ok

        {{:error, :not_found}, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug("Appsignal.Broadway attached to #{inspect(event)}")

          :ok

        {_, {:error, _} = error} ->
          Logger.warning(
            "Appsignal.Broadway not attached to #{inspect(event)}: #{inspect(error)}"
          )

          error
      end
    end
  end

  def broadway_processor_start(_event, _measurements, metadata, _config) do
    %{
      topology_name: topology_name,
      name: name,
      processor_key: processor_key,
      index: index,
      messages: messages,
      telemetry_span_context: telemetry_span_context,
      producer: producer
    } = metadata

    "broadway"
    |> @tracer.create_span()
    |> @span.set_attribute("appsignal:category", "processor.broadway")
    |> @span.set_name("#{inspect(topology_name)}#prepare_messages/2")
    |> @span.set_attribute("index", index)
    |> @span.set_attribute("message_count", length(messages))
    |> @span.set_attribute("processor_key", to_string(processor_key))
    |> @span.set_attribute("name", inspect(name))
    |> @span.set_attribute("topology_name", inspect(topology_name))
    |> @span.set_attribute("telemetry_span_context", inspect(telemetry_span_context))
    |> @span.set_attribute("producer", inspect(producer))
    |> IO.inspect(label: "broadway_processor_start")
  end

  def broadway_processor_stop(_event, %{duration: duration}, metadata, _config) do
    %{
      failed_messages: failed_messages,
      successful_messages_to_ack: to_ack,
      successful_messages_to_forward: to_forward
    } = metadata

    @tracer.current_span()
    |> @span.set_attribute("failed_messages", length(failed_messages))
    |> @span.set_attribute("successful_messages_to_ack", length(to_ack))
    |> @span.set_attribute("successful_messages_to_forward", length(to_forward))
    |> @span.set_attribute(
      "duration_ms",
      System.convert_time_unit(duration, :native, :millisecond)
    )
    |> IO.inspect(label: "broadway_processor_stop")
    |> @tracer.close_span()
  end

  def broadway_batch_processor_start(_event, _measurements, metadata, _config) do
    %{
      topology_name: topology_name,
      name: name,
      index: index,
      messages: messages,
      batch_info: batch_info,
      telemetry_span_context: telemetry_span_context,
      producer: producer
    } = metadata

    current_span = @tracer.current_span()

    "broadway"
    |> @tracer.create_span(current_span)
    |> @span.set_attribute("appsignal:category", "batch_processor.broadway")
    |> @span.set_name("#{inspect(topology_name)}#handle_batch/#{batch_info.batcher}")
    |> @span.set_attribute("index", index)
    |> @span.set_attribute("message_count", length(messages))
    |> @span.set_attribute("name", inspect(name))
    |> @span.set_attribute("topology_name", inspect(topology_name))
    |> @span.set_attribute("telemetry_span_context", inspect(telemetry_span_context))
    |> @span.set_attribute("producer", inspect(producer))
    |> set_batch_info(batch_info)
    |> IO.inspect(label: "broadway_batch_processor_start")
  end

  def broadway_batch_processor_stop(_event, %{duration: duration}, metadata, _config) do
    %{
      successful_messages: successful_messages,
      failed_messages: failed_messages,
      batch_info: batch_info
    } = metadata

    @tracer.current_span()
    |> @span.set_attribute("successful_messages", length(successful_messages))
    |> @span.set_attribute("failed_messages", length(failed_messages))
    |> @span.set_attribute(
      "duration_ms",
      System.convert_time_unit(duration, :native, :millisecond)
    )
    |> set_batch_info(batch_info)
    |> IO.inspect(label: "broadway_batch_processor_stop")
    |> @tracer.close_span()
  end

  defp set_batch_info(span, %Broadway.BatchInfo{} = batch_info) do
    span
    |> @span.set_attribute("batcher", to_string(batch_info.batcher))
    |> @span.set_attribute("batch_key", inspect(batch_info.batch_key))
    |> @span.set_attribute("batch_size", batch_info.size)
    |> @span.set_attribute("batch_trigger", to_string(batch_info.trigger))
    |> @span.set_attribute("batch_partition", inspect(batch_info.partition))
  end

  def broadway_message_start(_event, _measurements, metadata, _config) do
    %{
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
      context: _context,
      telemetry_span_context: telemetry_span_context,
      producer: producer,
      topology_name: topology_name,
      processor_key: processor_key
    } = metadata

    current_span = @tracer.current_span()
    span = @tracer.create_span("broadway", current_span)

    span
    |> @span.set_attribute("appsignal:category", "processor_message.broadway")
    |> @span.set_name("#{inspect(topology_name)}#handle_message/3")
    |> @span.set_sample_data("message", to_string(inspect(message)))
    |> @span.set_attribute("index", index)
    |> @span.set_attribute("processor_key", processor_key)
    |> @span.set_attribute("topology_name", topology_name)
    |> @span.set_attribute("telemetry_span_context", telemetry_span_context)
    |> @span.set_attribute("producer", producer)
    |> IO.inspect(label: "broadway_message_start")
  end

  def broadway_message_stop(
        _event,
        _measurements,
        %{
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
          context: _context,
          telemetry_span_context: telemetry_span_context,
          producer: producer,
          topology_name: topology_name,
          processor_key: processor_key
        },
        _config
      ) do
    span = @tracer.current_span()

    span
    |> @span.set_attribute("appsignal:category", "processor_message.broadway")
    |> @span.set_sample_data("message", to_string(inspect(message)))
    |> @span.set_attribute("index", index)
    |> @span.set_attribute("processor_key", processor_key)
    |> @span.set_attribute("topology_name", topology_name)
    |> @span.set_attribute("telemetry_span_context", telemetry_span_context)
    |> @span.set_attribute("producer", producer)
    |> IO.inspect(label: "broadway_message_stop")
    |> @tracer.close_span()
  end

  def broadway_topology_init(
        _event,
        %{system_time: system_time},
        %{supervisor_pid: supervisor_pid, config: config},
        _config
      ) do
    span = @tracer.create_span("broadway")

    span
    |> @span.set_attribute("appsignal:category", "topology_init.broadway")
    |> @span.set_attribute("system_time", system_time)
    |> @span.set_attribute("supervisor_pid", supervisor_pid)
    |> @span.set_attribute("config", config)
    |> IO.inspect(label: "broadway_topology_init")
    |> @tracer.close_span()
  end

  def log_exception(_event, _measurements, metadata, _config) do
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
         context: _context,
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
    |> @span.set_name("#{inspect(topology_name)}#handle_message/3")
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
    |> IO.inspect(label: "broadway_exception")
    |> @tracer.close_span()
  end
end
