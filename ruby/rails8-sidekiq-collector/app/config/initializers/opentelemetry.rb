require "socket"
require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"
require "opentelemetry-exporter-otlp"

OpenTelemetry::SDK.configure do |c|
  # Add AppSignal and app configuration
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    "appsignal.config.name" => ENV["APPSIGNAL_APP_NAME"],
    "appsignal.config.environment" => Rails.env.to_s,
    "appsignal.config.push_api_key" => ENV["APPSIGNAL_PUSH_API_KEY"],
    "appsignal.config.revision" => "test-setups",
    "appsignal.config.language_integration" => "ruby",
    "host.name" => Socket.gethostname,
  )
  # Customize the service name
  c.service_name =
    if Sidekiq.server?
      "Sidekiq worker"
    else
      "Rails server"
    end

  # Configure the OpenTelemetry HTTP exporter
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        :endpoint => "http://appsignal-collector:8099/v1/traces",
        :compression => "none"
      )
    )
  )

  c.use_all # enables all instrumentation!
end
