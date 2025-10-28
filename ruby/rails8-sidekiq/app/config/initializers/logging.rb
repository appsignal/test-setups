# Prepend all log lines with the following tags.
Rails.application.config.log_tags = {
  request_id: :request_id,
  ip: :remote_ip,
  referer: ->(request) { request.headers["Referer"] }
}

# Semantic logger example
# Disable the Rails.logger config above this when you enable the config below
# log_filter = ->(log) { log.payload&.[](:path) != "/up".freeze }
# # if ENV["RAILS_LOG_TO_STDOUT"].present?
#   $stdout.sync = true
#   Rails.application.config.rails_semantic_logger.add_file_appender = false
#   Rails.application.config.rails_semantic_logger.semantic = true
#   Rails.application.config.rails_semantic_logger.format = :logfmt
#   Rails.application.config.semantic_logger.add_appender(io: $stdout, formatter: :logfmt, filter: log_filter)
# # end
#
# appsignal_logger = Appsignal::Logger.new("rails", format: Appsignal::Logger::LOGFMT)
# SemanticLogger.add_appender(logger: appsignal_logger, formatter: :logfmt, filter: log_filter)
#
# # Log to STDOUT by default
# Rails.application.config.logger = ActiveSupport::Logger.new(STDOUT)
#   .tap { |logger| logger.formatter = ::Logger::Formatter.new }
#   .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
#
