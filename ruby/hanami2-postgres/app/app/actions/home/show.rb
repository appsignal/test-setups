module Hanami2Postgres
  module Actions
    module Home
      class Show < Hanami2Postgres::Action
        def handle(request, response)
          response.body = "Hello from action #{self.class.name}: #{request.params.to_h}"
        end
      end
    end
  end
end
