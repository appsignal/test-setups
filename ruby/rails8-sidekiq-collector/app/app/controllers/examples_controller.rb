class ReportError < StandardError; end

class ExamplesController < ApplicationController
  def index
    session[:user_id] = :some_user_id_123
    session[:menu] = { :state => :open, :view => :full }

    span = OpenTelemetry::Trace.current_span
    span.set_attribute("appsignal.request.parameters", JSON.dump({
      "password": "super secret",
      "email": "test@example.com",
      "cvv": 123,
      "test_param": "test value",
      "nested": {
        "password": "super secret nested",
        "test_param": "test value",
      }
    }))
    span.set_attribute("appsignal.request.session_data", JSON.dump({
      "token": "super secret",
      "user_id": 123,
      "test_param": "test value",
      "nested": {
        "token": "super secret nested",
        "test_param": "test value",
      }
    }))
    span.set_attribute("appsignal.function.parameters", JSON.dump({
      "hash": "super secret",
      "salt": "shoppai",
      "test_param": "test value",
      "nested": {
        "hash": "super secret nested",
        "test_param": "test value",
      }
    }))
  end

  def slow
    sleep 3
  end

  def error
    raise "This is a Rails error!"
  end

  def error_cause
    CauseCauser.new.error
  rescue => e
    puts e.backtrace
    render :html => "foo"
  end

  def custom_error
    raise "uh oh"
  rescue StandardError
    raise
  end

  def error_reporter
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    render :html => "An error has been reported through the Rails error reporter"
  end

  def queries
    user_count = User.count
    User.destroy_all if user_count > 10_000

    2.times do |i|
      User.create!(:name => "User ##{user_count + i}")
    end
    @users = User.all
  end
end

class CauseCauser
  class WrappedError < StandardError; end
  class ExampleError < StandardError; end

  def error
    example_error
  rescue
    raise WrappedError, "my wrapped error message"
  end

  private

  def example_error
    deep_error
  rescue
    raise ExampleError, "my example error message"
  end

  def deep_error
    raise "Original error cause"
  end
end
