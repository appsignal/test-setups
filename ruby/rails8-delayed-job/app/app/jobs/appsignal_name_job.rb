# A Delayed Job job that overrides its AppSignal action name through the
# `appsignal_name` method. When it performs, the transaction's action is the
# `appsignal_name` value rather than the job class name.
class AppsignalNameJob
  def deliver(argument = nil)
    puts "delivered AppsignalNameJob: #{argument}"
  end

  def deliver_async(argument = nil)
    deliver(argument)
  end
  handle_asynchronously :deliver_async, :queue => "default"

  def appsignal_name
    "AppsignalNameJob#custom_action"
  end
end
