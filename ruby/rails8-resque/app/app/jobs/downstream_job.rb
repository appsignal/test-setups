# Enqueued by this app but performed by the separately-instrumented downstream
# service, which is the only worker draining the `downstream` queue. In collector
# mode the trace context rides along on the Resque payload, so the job's trace
# (under the downstream app) links back to the enqueue span (under this app) --
# job trace propagation across two services.
class DownstreamJob
  @queue = :downstream

  def self.perform(argument = nil)
    sleep 1
    puts "downstream performed #{argument}!"
  end
end
