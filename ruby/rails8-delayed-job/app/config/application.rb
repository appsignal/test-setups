require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ExampleApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    config.active_job.queue_adapter = :delayed_job

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
    config.hosts << "app" << "localhost"

    # Add custom log tags
    # config.log_tags = [ :request_id, :ip, ->(request) { request.headers["Referer"] } ]
    # # Set up standard out logger
    # console_logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
    # # Set up AppSignal logger
    # appsignal_logger = ActiveSupport::TaggedLogging.new(Appsignal::Logger.new("rails"))
    # # Broadcast the logs to both backends
    # config.logger = ActiveSupport::BroadcastLogger.new(console_logger, appsignal_logger)

    # appsignal_logger = Appsignal::Logger.new("rails", level: Appsignal::Logger::DEBUG)
    # # console_logger = Logger.new(STDOUT)
    # # appsignal_logger.broadcast_to(console_logger)
    # file_logger = Logger.new(Rails.root.join("log/#{Rails.env}.log"))
    # appsignal_logger.broadcast_to(file_logger)
    # # appsignal_logger.broadcast_to(config.logger)
    # config.logger = ActiveSupport::TaggedLogging.new(appsignal_logger)
  end
end

# ActiveSupport::Notifications.subscribe(/.*/) do |event|
#   # Do stuff
#   puts "!!! event: #{event}"
# end
