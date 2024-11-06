# frozen_string_literal: true

module Hanami2Postgres
  class Routes < Hanami::Routes
    root to: "home.show"
    post "/", to: "home.show"
    get "/slow", to: "slow.show"
    get "/error", to: "errors.show"
    get "/books", to: "books.index"
    get "/books/:id", to: "books.show"
    post "/books", to: "books.create"
  end
end
