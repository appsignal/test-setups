Rails.application.configure do
  config.log_tags = [:request_id]

  # TODO: This doesn't work to what appears to be a bug in Rails and/or Good Job when queuing a job.
  # appsignal_logger = ActiveSupport::TaggedLogging.new(Appsignal::Logger.new("rails"))
  appsignal_logger = Appsignal::Logger.new("rails")

  Rails.logger.broadcast_to appsignal_logger
end
