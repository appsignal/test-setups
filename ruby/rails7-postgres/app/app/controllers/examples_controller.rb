class ExamplesController < ApplicationController
  def slow
    sleep 3
  end

  def error
    raise "This is a Rails error!"
  end

  class StreamingSlowBody
    def each
      sleep 1
      yield "1"
      sleep 1
      yield "2"
      sleep 1
      yield "3"
      sleep 1
      yield "4"
    end
  end

  def streaming_slow
    headers["Content-Length"] = "4"
    headers["Last-Modified"] = Time.now.httpdate
    self.response_body = StreamingSlowBody.new
  end

  class StreamingErrorBody
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
    headers["Last-Modified"] = Time.now.httpdate
    self.response_body = StreamingErrorBody.new
  end
end
