class ActiveJobPerformanceJob < ActiveJob::Base
  self.log_arguments = false
  queue_as :active_job_performance

  def perform(argument = nil, options = {})
    puts "delivered #{argument}!"
  end
end
