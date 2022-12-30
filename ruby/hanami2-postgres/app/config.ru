# frozen_string_literal: true

require "hanami/boot"
require "appsignal/integrations/hanami"

pp Hanami.app.config

run Hanami.app
