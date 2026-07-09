Appsignal.configure do |config|
  # This worker is booted with `rake jobs:work`. With rake performance
  # instrumentation on, the rake task opens a "rake" transaction that each job
  # reuses, so jobs are recorded under the "rake" namespace instead of
  # "background_job" (and lose their trace context in collector mode).
  # See https://github.com/appsignal/appsignal-ruby/issues/1536.
  config.enable_rake_performance_instrumentation = false

  config.activate_if_environment(:development, :production)
end
