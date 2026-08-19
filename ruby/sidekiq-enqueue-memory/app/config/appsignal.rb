Appsignal.configure do |config|
  # `enable_job_enqueue_instrumentation` is deliberately left alone here so the
  # experiment is driven entirely by the
  # APPSIGNAL_ENABLE_JOB_ENQUEUE_INSTRUMENTATION environment variable. Setting
  # it in this file would override the variable and quietly pin every run to
  # the same value.
  config.activate_if_environment(:development, :production)
end
