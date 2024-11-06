module Hanami2Postgres
  module Actions
    module Home
      class Show < Hanami2Postgres::Action
        def handle(request, response)
          response.body = "Hello from action #{self.class.name}: #{request.params.to_h}"
          response.body = <<~HTML
              Hello from action #{self.class.name}: #{request.params.to_h}"

              <form action="/?test_query_param=my_test" method="post">
                <input type="text" name="my_input" />
                <button>Submit</button>
              </form>
            HTML
        end
      end
    end
  end
end
