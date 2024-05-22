require "./app"

class MyMiddleware
  def initialize(app, opts = {}, &block)
    @app = app
  end

  def call(env)
    app_response =
      Appsignal.instrument "call_app.my_middleware" do
        # Call app beforehand, triggering the AppSignal middleware
        @app.call(env)
      end
    # When this query string is found, ignore the app response and return something else instead.
    if env["QUERY_STRING"].include?("tomsvar=1")
      Appsignal.instrument("early_return.my_middleware") do
        # Return something else, not handling the app's body will not close the
        # AppSignal transaction, creating the problematic transactions
        # recording multiple requests.
        [200, {}, ["Early return"]]
      end
    else
      app_response
    end
  end
end

use MyMiddleware
use Appsignal::Rack::GenericInstrumentation

run App.new
