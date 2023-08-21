class ErrorWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(argument = nil, options = {})
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    raise RetryJobError.new("Something went wrong 3")
  end
end

class RetryJobError < StandardError
  def initialize(msg="default message")
    super(msg)
  end
end
