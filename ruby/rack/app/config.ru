require "appsignal"

Appsignal.start

require_relative "app"

use ::Rack::Events, [Appsignal::Rack::EventHandler.new]
run MyApp.new
