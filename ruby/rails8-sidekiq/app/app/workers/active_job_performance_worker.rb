class ActiveJobPerformanceWorker < ActiveJob::Base
  queue_as :default

  def perform(argument = nil, options = {})
    puts "delivered #{argument}!"
  end
end
