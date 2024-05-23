require "./app"

class MyEarlyReturnMiddleware
  def initialize(app, opts = {}, &block)
    @app = app
  end

  def call(env)
    puts "!!! MyMiddleware: start"
    app_response =
      Appsignal.instrument "call_app.my_middleware" do
        # Call app beforehand, triggering the AppSignal middleware
        @app.call(env)
      end
    puts "!!! MyMiddleware: after app call"
    # When this query string is found, ignore the app response and return something else instead.
    if env["QUERY_STRING"].include?("tomsvar=1")
      Appsignal.instrument("early_return.my_middleware") do
        # Return something else, not handling the app's body will not close the
        # AppSignal transaction, creating the problematic transactions
        # recording multiple requests.
        puts "!!! MyMiddleware: early return"
        [200, {}, ["Early return"]]
      end
    else
      app_response
    end
  end
end

class MyBrokenMiddleware
  def initialize(app, opts = {}, &block)
    @app = app
  end

  def call(env)
    response =
      Appsignal.instrument("call_app.my_other_middleware") do
        @app.call(env)
      end
    if env["QUERY_STRING"].include?("tomsvar=2")
      puts "!!! MyOtherMiddleware: raise error"
      raise "uh oh"
    end
    response
  end
end

APPSIGNAL_TRANSACTION = "__appsignal.transaction"

class EventHandler
  include ::Rack::Events::Abstract

  def on_start(request, _response)
    puts
    puts "!!! on_start: #{request.request_method} #{request.path}"
    transaction = Appsignal::Transaction.create(
      SecureRandom.uuid,
      Appsignal::Transaction::HTTP_REQUEST,
      request
    )
    transaction.start_event
    request.env[APPSIGNAL_TRANSACTION] = transaction
  end

  def on_error(request, _response, error)
    puts "!!! on_error: #{error}"
    transaction = request.env[APPSIGNAL_TRANSACTION]
    return unless transaction

    transaction.set_error(error)
  end

  def on_finish(request, response)
    puts "!!! on_finish"
    transaction = request.env[APPSIGNAL_TRANSACTION]
    return unless transaction

    puts "!!! on_finish: close transaction"
    transaction.finish_event("process_request.rack", "", "")
    transaction.set_action_if_nil("#{request.request_method} #{request.path}")
    transaction.set_metadata("path", request.path)
    transaction.set_metadata("method", request.request_method)
    transaction.set_http_or_background_queue_start

    Appsignal::Transaction.complete_current!
  end
end

class AppsignalInstrumentation
  def initialize(app)
    @app = app
  end

  def call(env)
    transaction = env[APPSIGNAL_TRANSACTION]
    if transaction
      call_with_appsignal_monitoring(env, transaction)
    else
      nil_transaction = Appsignal::Transaction::NilTransaction.new
      status, headers, obody = @app.call(env)
      [status, headers, Appsignal::Rack::BodyWrapper.wrap(obody, nil_transaction)]
    end
  end

  def call_with_appsignal_monitoring(env, transaction)
    transaction.start_event

    status, headers, obody = @app.call(env)
    [status, headers, Appsignal::Rack::BodyWrapper.wrap(obody, transaction)]
  ensure
    transaction.finish_event("process_action.rack", "", "")
  end
end

use Rack::Events, [EventHandler.new]
use AppsignalInstrumentation
# use MyEarlyReturnMiddleware
use MyBrokenMiddleware
# use Appsignal::Rack::GenericInstrumentation

run App.new
