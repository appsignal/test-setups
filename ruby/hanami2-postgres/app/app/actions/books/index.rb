module Hanami2Postgres
  module Actions
    module Books
      class Index < Hanami2Postgres::Action
        include Deps["persistence.rom"]

        params do
          optional(:page).value(:integer, gt?: 0)
          optional(:per_page).value(:integer, gt?: 0, lteq?: 100)
        end

        def handle(request, response)
          halt 422 unless request.params.valid?

          books = rom.relations[:books]
            .select(:title, :author)
            .order(:title)
            .page(request.params[:page] || 1)
            .per_page(request.params[:per_page] || 5)
            .to_a

          response.format = :json
          response.body = books.to_json
        end
      end
    end
  end
end
