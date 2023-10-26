Rails.application.configure do
  config.active_job.queue_adapter = :good_job
  config.good_job.execution_mode = :external
end
