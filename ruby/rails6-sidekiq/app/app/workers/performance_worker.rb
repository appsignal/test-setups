class PerformanceWorker
  include Sidekiq::Worker

  def perform(argument = nil, options = {})
    sleep 1
    puts "delivered #{argument}!"
  end
end
