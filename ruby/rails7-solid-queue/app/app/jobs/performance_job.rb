class PerformanceJob < ApplicationJob
  def perform(argument)
    sleep 1
    puts "delivered #{argument}!"
  end
end
