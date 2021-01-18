class SingleWorker
  include Shoryuken::Worker

  shoryuken_options \
    :queue => "default",
    :auto_delete => true,
    :body_parser => :json

  def perform(sqs_msg, body)
    # Do stuff
    puts "Performing SingleWorker job: #{body}"
    sleep 1
  end
end
