Appsignal.configure do |config|
  config.instrument_sequel = false

  config.activate_if_environment(:development, :production)
end

