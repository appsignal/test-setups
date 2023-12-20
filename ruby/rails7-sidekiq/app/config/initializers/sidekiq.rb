# Not necessary -- `rails_semantic_logger` automatically configures
# itself for Sidekiq.
#
# Sidekiq.configure_server do |config|
#   console_logger = ActiveSupport::Logger.new(STDOUT)
#   appsignal_logger = Appsignal::Logger.new("sidekiq")
#   config.logger = ActiveSupport::BroadcastLogger.new(console_logger, appsignal_logger)
#   config.logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new
# end
