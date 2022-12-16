# frozen_string_literal: true

require "hanami"
require "appsignal"

module Hanami2Postgres
  class App < Hanami::App
    config.middleware.use :body_parser, :json
  end
end
