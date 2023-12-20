appsignal_logger = ActiveSupport::TaggedLogging.new(Appsignal::Logger.new("rails", format: Appsignal::Logger::LOGFMT))
SemanticLogger.add_appender(logger: appsignal_logger, formatter: :logfmt)
