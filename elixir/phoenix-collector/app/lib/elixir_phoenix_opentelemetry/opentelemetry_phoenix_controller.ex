defmodule OpentelemetryPhoenixController do
  require OpenTelemetry.Tracer

  @tracer_id __MODULE__

  def setup do
    attach_controller_render_handlers()
  end

  def attach_controller_render_handlers do
    :telemetry.attach_many(
      {__MODULE__, :controller_render},
      [
        [:phoenix, :controller, :render, :start],
        [:phoenix, :controller, :render, :stop],
        [:phoenix, :controller, :render, :exception]
      ],
      &__MODULE__.handle_controller_render_event/4,
      %{}
    )

    :ok
  end

  def handle_controller_render_event(
        [:phoenix, :controller, :render, :start],
        _measurements,
        %{view: view, template: template, format: format} = metadata,
        _handler_configuration
      ) do
    OpentelemetryTelemetry.start_telemetry_span(
      @tracer_id,
      "Render #{inspect(template)} (#{format}) template from #{module_name(view)}",
      metadata,
      %{kind: :server}
    )
  end

  def handle_controller_render_event(
        [:phoenix, :controller, :render, :stop],
        _measurements,
        metadata,
        _handler_configuration
      ) do
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
  end

  def handle_controller_render_event(
        [:phoenix, :controller, :render, :exception],
        _measurements,
        %{kind: kind, reason: reason, stacktrace: stacktrace} = metadata,
        _handler_configuration
      ) do
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, metadata)

    exception = Exception.normalize(kind, reason, stacktrace)

    OpenTelemetry.Span.record_exception(ctx, exception, stacktrace, [])
    OpenTelemetry.Span.set_status(ctx, OpenTelemetry.status(:error, ""))
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
  end

  defp module_name("Elixir." <> module), do: module
  defp module_name(module) when is_binary(module), do: module
  defp module_name(module), do: module |> to_string() |> module_name()
end
