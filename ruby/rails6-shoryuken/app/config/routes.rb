Rails.application.routes.draw do
  get "/slow", to: "tests#slow"
  get "/error", to: "tests#error"
  get "/streaming-error", to: "tests#streaming_error_in_body"
  get "/active_job_performance_job", to: "tests#active_job_performance_job"
  get "/active_job_error_job", to: "tests#active_job_error_job"
  root :to => "tests#index"
end
