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
      sleep 0.5
      yield "2"
      yield "3"
      raise "Rails error in streaming body"
    end
  end

  def streaming_error_in_body
    headers["Content-Length"] = "4"
    response.body = StreamingBody.new
  end
end
