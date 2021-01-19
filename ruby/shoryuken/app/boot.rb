require "shoryuken"
require "json"
require "appsignal"

Appsignal.config = Appsignal::Config.new(
  File.expand_path(File.dirname(__FILE__)),
  "production"
)
Appsignal.start
Appsignal.start_logger

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
