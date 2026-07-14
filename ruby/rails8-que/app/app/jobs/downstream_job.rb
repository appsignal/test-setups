# Enqueued by this app onto the `downstream` queue but performed by the
# separately-instrumented downstream service, which is the only worker draining
# that queue. In collector mode the trace context rides along on the Que job
# (via a Que tag), so the job's trace (under the downstream app) links back to
# the enqueue span (under this app) -- job trace propagation across two services.
class DownstreamJob < Que::Job
  def run(argument = nil)
    sleep 1
    puts "downstream performed #{argument}!"
  end
end
