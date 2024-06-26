require "appsignal"

Appsignal.config = Appsignal::Config.new(
  Dir.pwd,
  ENV.fetch("RACK_ENV", "development")
)
Appsignal.start
Appsignal.start_logger

require_relative "api"

use ::Rack::Events, [Appsignal::Rack::EventHandler.new]

MyApp::API.compile!
run MyApp::API
