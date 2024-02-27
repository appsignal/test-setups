require_relative '../../app/middleware/appsignal_namespace_middleware'

Sidekiq.configure_server do |config|
  console_logger = ActiveSupport::Logger.new(STDOUT)
  appsignal_logger = Appsignal::Logger.new("sidekiq")
  config.logger = ActiveSupport::BroadcastLogger.new(console_logger, appsignal_logger)
  config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new
  config.server_middleware do |chain|
    chain.add AppsignalNamespaceMiddleware
  end
end
