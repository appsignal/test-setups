# A native Shoryuken worker (as opposed to the Active Job jobs in app/jobs).
# Enqueuing it with `NativeWorker.perform_async` from a web request records an
# `enqueue.shoryuken` event on that request's transaction, through Shoryuken's
# client middleware. It uses its own queue so it doesn't clash with the Active
# Job adapter, which owns the "default" queue.
class NativeWorker
  include Shoryuken::Worker

  shoryuken_options :queue => "native", :auto_delete => true, :body_parser => :json

  def perform(_sqs_msg, body)
    puts "Performing NativeWorker job: #{body}"
  end
end
