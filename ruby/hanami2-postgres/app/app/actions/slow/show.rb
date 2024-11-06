# frozen_string_literal: true

module ExampleApp
  module Actions
    module Slow
      class Show < ExampleApp::Action
        def handle(request, response)
          sleep 3
        end
      end
    end
  end
end
