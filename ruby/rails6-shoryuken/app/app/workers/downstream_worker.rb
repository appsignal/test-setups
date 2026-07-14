# A native Shoryuken worker enqueued by this app but performed by the
# separately-instrumented downstream service, which is the only worker draining
# the `downstream` queue. In collector mode the trace context rides along on an
# SQS message attribute, so the job's trace (under the downstream app) links back
# to the enqueue span (under this app) -- job trace propagation across services.
class DownstreamWorker
  include Shoryuken::Worker

  shoryuken_options :queue => "downstream", :auto_delete => true, :body_parser => :json

  def perform(_sqs_msg, body)
    puts "downstream performed Shoryuken job: #{body}"
  end
end
