# frozen_string_literal: true

require "hanami/boot"
require 'appsignal'

Appsignal.config = Appsignal::Config.new(
  File.expand_path('../', __FILE__),
  'development'
)

Appsignal.start                               # Start the AppSignal integration
Appsignal.start_logger
use Appsignal::Rack::GenericInstrumentation
run Hanami.rack_app
