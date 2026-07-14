# Enqueued by the `app` service but performed by the `downstream` service, which
# is the only one draining the `downstream` queue. In collector mode the trace
# context rides along on the job payload, so the job's trace (under the
# downstream app) links back to the enqueue span (under this app) -- job trace
# propagation across two services.
class DownstreamWorker
  include Sidekiq::Worker
  sidekiq_options :queue => "downstream"

  def perform(argument = nil)
    sleep 1
    puts "downstream performed #{argument}!"
  end
end
