# Load the Rails application.
require_relative "application"

Rails.logger = Appsignal::Logger.new("rails", Logger::DEBUG)

# Initialize the Rails application.
Rails.application.initialize!
