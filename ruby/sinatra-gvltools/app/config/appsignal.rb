Appsignal.configure do |config|
  config.activate_if_environment(:test, :development, :production)
end