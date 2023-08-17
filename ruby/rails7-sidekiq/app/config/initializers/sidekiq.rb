Sidekiq.configure_server do |config|
  console_logger = ActiveSupport::Logger.new(STDOUT)
  config.logger = console_logger.extend(ActiveSupport::Logger.broadcast(Appsignal::Logger.new("sidekiq")))
  config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new
end
