Sidekiq.configure_server do |config|
  config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new
end
