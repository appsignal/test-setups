class ExamplesController < ApplicationController
  def slow
    sleep 3
  end

  def error
    raise "This is a Rails error!"
  end

  class StreamingBody
    def each
      yield "1"
      yield "2"
      yield "3"
      raise "Rails error in streaming body"
    end
  end

  def streaming_error_in_body
    headers["Content-Length"] = "4"
    response.body = StreamingBody.new
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
