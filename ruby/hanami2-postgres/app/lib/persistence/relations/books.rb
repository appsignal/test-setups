module ExampleApp
  module Relations
    class Books < ExampleApp::DB::Relation
      schema :books, infer: true
    end
  end
end
