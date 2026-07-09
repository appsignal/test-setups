Appsignal.configure do |config|
  config.enable_rake_performance_instrumentation = false
  
  config.activate_if_environment(:development, :production)
end
