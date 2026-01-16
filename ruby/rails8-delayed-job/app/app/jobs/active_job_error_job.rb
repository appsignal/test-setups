class ActiveJobErrorJob < ActiveJob::Base
  queue_as :active_job_errors
  # Enable this to use the Active Job retry mechanism
  # Use the version where the `wait` config is a proc when you don't want it
  # to do a longer wait time the more retries it does
  # See also the config/initializers/delayed_job_config.rb file to disable the Delayed Job retry
  # mechanism, which is ~required to enable this
  # retry_on StandardError, wait: 10.seconds
  # retry_on StandardError, wait: ->(_executions) { 10.seconds }

  def perform(argument = nil, options = {})
    Rails.error.handle do
      1 + '1' # raises TypeError
    end
    raise "Error #{argument}"
  end
end
