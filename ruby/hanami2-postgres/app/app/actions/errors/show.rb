module Hanami2Postgres
  module Actions
    module Errors
      class Show < Hanami2Postgres::Action
        def handle(request, response)
          raise "This is an error from an Hanami action"
        end
      end
    end
  end
end
