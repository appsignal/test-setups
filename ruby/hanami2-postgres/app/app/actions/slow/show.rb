module Hanami2Postgres
  module Actions
    module Slow
      class Show < Hanami2Postgres::Action
        def handle(request, response)
          sleep 3
          response.body = "Well that was slow"
        end
      end
    end
  end
end
