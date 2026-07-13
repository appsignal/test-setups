class ActiveJobErrorWorker < ActiveJob::Base
  queue_as :default

  def perform(argument = nil, options = {})
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    raise "Error #{argument}"
  end
end
