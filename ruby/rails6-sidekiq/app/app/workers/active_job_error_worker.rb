class ActiveJobErrorWorker < ActiveJob::Base
  # queue_as :default
  sidekiq_options :retry => 3

  def perform(argument = nil, options = {})
    raise "Error #{argument}"
  end
end
