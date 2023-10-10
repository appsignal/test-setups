console_logger = ActiveSupport::Logger.new(STDOUT)
appsignal_logger = ActiveSupport::TaggedLogging.new(Appsignal::Logger.new("rails"))
Rails.application.config.log_tags = [:request_id]
Rails.logger = ActiveSupport::BroadcastLogger.new(console_logger, appsignal_logger)
