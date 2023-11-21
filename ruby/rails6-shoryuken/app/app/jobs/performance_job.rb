class PerformanceJob < ApplicationJob
  queue_as :default

  def perform(msg)
    puts "Performing DefaultJob with msg: #{msg}"
    sleep 1
  end
end
