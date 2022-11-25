Sidekiq.configure_server do |config|
  config.logger = Appsignal::Logger.new("sidekiq")
  config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new
end
