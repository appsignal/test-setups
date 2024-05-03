require "opentelemetry/sdk"
require "opentelemetry/instrumentation/all"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "Rails server"
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    "appsignal.config.app_name" => ENV.fetch("APPSIGNAL_APP_NAME"),
    "appsignal.config.app_environment" => ENV.fetch("APPSIGNAL_APP_ENV"),
    "appsignal.config.push_api_key" => ENV.fetch("APPSIGNAL_PUSH_API_KEY"),
    "appsignal.config.app_path" => Rails.root.to_s
  )
  c.use_all() # enables all instrumentation!
end

puts "!!! opentelemetry start"
