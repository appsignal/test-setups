class ErrorJob
  def deliver(argument = nil, options = {})
    raise "Error #{argument}"
  end

  def deliver_async(argument = nil, options = {})
    deliver(argument, options)
  end
  handle_asynchronously :deliver_async, :queue => "errors"
end
