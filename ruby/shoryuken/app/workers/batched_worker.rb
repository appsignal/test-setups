class BatchedWorker
  include Shoryuken::Worker

  shoryuken_options \
    :queue => "batched",
    :auto_delete => true,
    :body_parser => :json,
    :batch => true

  def perform(sqs_msg, body)
    # Do stuff
    puts "Performing BatchedWorker job: #{body}"
    sleep 1
  end
end
