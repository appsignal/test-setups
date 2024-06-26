# auto_register: false
# frozen_string_literal: true

require "hanami/action"

module Hanami2Postgres
  class Action < Hanami::Action
    handle_exception StandardError => :handle_standard_error

    private

    def handle_standard_error(request, response, exception)
      # Report the error to AppSignal
      Appsignal.set_error(exception)

      # Render custom error page
      response.status = 500
      response.body = "Sorry, something went wrong handling your request"
    end
  end
end
