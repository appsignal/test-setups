# frozen_string_literal: true

module ExampleApp
  class Routes < Hanami::Routes
    root to: "home.show"
    post "/", to: "home.show"

    get "/slow", to: "slow.show"
    get "/error", to: "error.show"
    get "/books", to: "books.index"
  end
end
