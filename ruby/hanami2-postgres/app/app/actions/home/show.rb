module Hanami2Postgres
  module Actions
    module Home
      class Show < Hanami2Postgres::Action
        def handle(*, response)
          response.body = self.class.name
        end
      end
    end
  end
end
