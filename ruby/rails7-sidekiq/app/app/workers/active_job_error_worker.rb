class ActiveJobErrorWorker < ActiveJob::Base
  queue_as :default
  sidekiq_options :retry => 3

  def perform(argument = nil, options = {})
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    raise "Error #{argument}"
  end
end
