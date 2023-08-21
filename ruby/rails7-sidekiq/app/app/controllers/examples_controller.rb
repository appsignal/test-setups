class ExamplesController < ApplicationController

  def error
    raise RetryJobError.new("Something went wrong 2")
  end
end

class RetryJobError < StandardError
  def initialize(msg="default message")
    super(msg)
  end
end
