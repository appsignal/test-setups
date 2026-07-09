Appsignal.configure do |config|
  config.enable_rake_performance_instrumentation = true
  
  config.activate_if_environment(:development, :production)
end
