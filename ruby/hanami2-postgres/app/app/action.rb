# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module ExampleApp
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    handle_exception StandardError => :handle_standard_error

    private

    def handle_standard_error(request, response, exception)
      # Report the error to AppSignal
      Appsignal.report_error(exception)

      # Render custom error page
      response.status = 500
      response.body = "Sorry, something went wrong handling your request"
    end
  end
end
