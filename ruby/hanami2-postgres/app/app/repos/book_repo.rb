module ExampleApp
  module Repos
    class BookRepo < ExampleApp::DB::Repo
      def all_by_title
        books.order(books[:title].asc).to_a
      end
    end
  end
end
