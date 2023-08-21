class ActiveJobErrorWorker < ActiveJob::Base
  queue_as :default
  sidekiq_options :retry => 3

  def perform(argument = nil, options = {})
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    raise RetryJobError.new("Something went wrong 4")
  end
end

class RetryJobError < StandardError
  def initialize(msg="default message")
    super(msg)
  end
end
