Shoryuken.configure_client do |config|
  config.sqs_client = Aws::SQS::Client.new(
    region: ENV["AWS_REGION"],
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    endpoint: ENV["SHORYUKEN_SQS_ENDPOINT"],
    verify_checksums: false # Disable for mock server
  )
end

Shoryuken.configure_server do |config|
  config.sqs_client = Aws::SQS::Client.new(
    region: ENV["AWS_REGION"],
    access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    endpoint: ENV["SHORYUKEN_SQS_ENDPOINT"],
    verify_checksums: false # Disable for mock server
  )
end

# Load the native worker on boot so it registers for its queue. In development
# classes load lazily, so without this the Shoryuken server wouldn't know to
# route the "native" queue to NativeWorker.
Rails.application.config.to_prepare do
  NativeWorker
end
