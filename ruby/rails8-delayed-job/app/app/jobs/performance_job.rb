class PerformanceJob
  def deliver(argument = nil, options = {})
    sleep 1
    puts "delivered #{argument}!"
  end

  def deliver_async(argument = nil, options = {})
    deliver(argument, options)
  end
  handle_asynchronously :deliver_async, :queue => "performance"
end
