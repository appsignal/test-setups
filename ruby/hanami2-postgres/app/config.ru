# frozen_string_literal: true

require "appsignal"
require "hanami/boot"

# Load the Hanami integration
Appsignal.load(:hanami)
# Start AppSignal
Appsignal.start

run Hanami.app
