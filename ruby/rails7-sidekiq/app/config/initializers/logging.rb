Rails.application.config.log_tags = [:request_id]
appsignal_logger = Appsignal::Logger.new("rails")
Rails.logger.broadcast_to(appsignal_logger)
