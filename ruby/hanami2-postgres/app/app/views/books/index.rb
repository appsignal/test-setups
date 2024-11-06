# frozen_string_literal: true

module ExampleApp
  module Views
    module Books
      class Index < ExampleApp::View
        include Deps["repos.book_repo"]

        expose :books do
          book_relation = Hanami.app["relations.books"]
          book_relation.delete
          count = book_relation.count
          5.times do |i|
            book_relation.insert(title: "Book #{count + i}", author: "Author #{count + i}")
          end
          book_repo.all_by_title
        end
      end
    end
  end
end
