# frozen_string_literal: true

module ExampleApp
  module Views
    module Error
      class Show < ExampleApp::View
        raise "This is an error from an Hanami action"
      end
    end
  end
end
