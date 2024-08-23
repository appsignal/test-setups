# frozen_string_literal: true

require "appsignal"
require "hanami/boot"

Appsignal.load(:hanami)
Appsignal.start

run Hanami.app
