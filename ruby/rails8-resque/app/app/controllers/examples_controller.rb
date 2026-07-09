class ReportError < StandardError; end

class ExamplesController < ApplicationController
  owner :examples

  def index
    Rails.logger.info(
      "Test log message",
      abc: "def",
      # Attribute value with quotes in them
      params: { "foo" => "bar", "abc" => "def" },
      # This tag should also show up
      final_tag: "test"
    )
    session[:user_id] = :some_user_id_123
    session[:menu] = { :state => :open, :view => :full }
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
    raise "Error with error cause"
  end

  def custom_error
    raise "uh oh"
  rescue StandardError => error
    Appsignal.send_error(error) do
      Appsignal.apply_request(request)
    end

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
