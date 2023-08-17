console_logger = ActiveSupport::Logger.new(STDOUT)
Rails.application.config.log_tags = [:request_id]
Rails.logger = console_logger.extend(ActiveSupport::Logger.broadcast(ActiveSupport::TaggedLogging.new(Appsignal::Logger.new("rails"))))
