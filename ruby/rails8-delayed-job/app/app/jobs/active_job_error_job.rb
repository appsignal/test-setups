class ActiveJobErrorJob < ActiveJob::Base
  queue_as :active_job_errors

  def perform(argument = nil, options = {})
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    raise "Error #{argument}"
  end
end
