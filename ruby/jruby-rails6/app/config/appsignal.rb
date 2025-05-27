Appsignal.configure do |config|
  config.activate_if_environment(:development, :production)
end
