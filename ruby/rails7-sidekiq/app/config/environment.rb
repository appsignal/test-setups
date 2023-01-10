# Load the Rails application.
require_relative "application"

# Use AppSignal's logger
Rails.logger = Appsignal::Logger.new("rails")

# Initialize the Rails application.
Rails.application.initialize!
