module Hanami2Postgres
  module Persistence
    module Relations
      class Books < ROM::Relation[:sql]
        schema(:books, infer: true)

        use :pagination
        per_page 5
      end
    end
  end
end
