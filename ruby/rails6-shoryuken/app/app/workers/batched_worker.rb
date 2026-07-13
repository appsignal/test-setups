# A batched native Shoryuken worker (see NativeWorker for the non-batched case).
# With `:batch => true`, Shoryuken delivers a group of SQS messages to a single
# `perform` call as arrays. AppSignal's Shoryuken integration instruments a
# batch differently from a single message: it tags the transaction with
# `batch => true`, records each message's body as a separate parameter keyed by
# its message ID, and does not link the transaction back to any enqueuer,
# because a batch can mix messages from several traces. It uses its own queue so
# it doesn't clash with the other workers.
class BatchedWorker
  include Shoryuken::Worker

  shoryuken_options :queue => "batched", :auto_delete => true, :body_parser => :json, :batch => true

  def perform(_sqs_msgs, bodies)
    puts "Performing BatchedWorker job with #{bodies.length} message(s)"
  end
end
