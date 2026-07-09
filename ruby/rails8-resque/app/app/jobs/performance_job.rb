# A native Resque job (a plain class with `@queue` and a `self.perform`),
# enqueued with `Resque.enqueue`. Enqueuing it from a web request records an
# `enqueue.resque` event on that request's transaction.
class PerformanceJob
  @queue = :default

  def self.perform(argument = nil)
    sleep 1
    puts "delivered #{argument}!"
  end
end
