require "appsignal"

Appsignal.config = Appsignal::Config.new(
  File.expand_path("../", __FILE__),
  ENV.fetch("RACK_ENV", "development")
)
Appsignal.start
Appsignal.start_logger

require_relative "app"

use ::Rack::Events, [Appsignal::Rack::EventHandler.new]
run MyApp.new
