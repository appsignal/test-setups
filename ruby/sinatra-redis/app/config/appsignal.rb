Appsignal.configure do |config|
  config.filter_metadata = ["path"]
  
  config.activate_if_environment(:test, :development, :production)
end