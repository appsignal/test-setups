# A native Que job (subclasses `Que::Job`, defines `run`), enqueued with
# `PerformanceJob.enqueue`. Enqueuing it from a web request records an
# `enqueue.que` event on that request's transaction.
class PerformanceJob < Que::Job
  def run(argument = nil)
    sleep 1
    puts "delivered #{argument}!"
  end
end
