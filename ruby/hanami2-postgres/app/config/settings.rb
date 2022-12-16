# frozen_string_literal: true

module Hanami2Postgres
  class Settings < Hanami::Settings
    setting :database_url, constructor: Types::String
  end
end
