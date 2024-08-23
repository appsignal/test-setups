require "appsignal"
require "grape"

use ::Rack::Events, [Appsignal::Rack::EventHandler.new]

Appsignal.load(:grape)
Appsignal.start

require_relative "api"

MyApp::API.compile!
run MyApp::API
