module Hanami2Postgres
  module Actions
    module Books
      class Show < Hanami2Postgres::Action
        include Deps["persistence.rom"]

        config.handle_exception ROM::TupleCountMismatchError => :handle_not_found

        params do
          required(:id).value(:integer)
        end

        def handle(request, response)
          book = rom.relations[:books].by_pk(
            request.params[:id]
          ).one!

          response.format = :json

          if book
            response.body = book.to_json
          else
            response.status = 404
            response.body = { error: "not_found" }.to_json
          end
        end

        private

        def handle_not_found(_request, response, _exception)
          response.status = 404
          response.format = :json
          response.body = { error: "not_found" }.to_json
        end
      end
    end
  end
end
