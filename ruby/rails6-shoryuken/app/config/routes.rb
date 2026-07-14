Rails.application.routes.draw do
  get "/slow", to: "tests#slow"
  get "/error", to: "tests#error"
  get "/active_job_performance_job", to: "tests#active_job_performance_job"
  get "/active_job_error_job", to: "tests#active_job_error_job"
  get "/shoryuken_native_job", to: "tests#shoryuken_native_job"
  get "/shoryuken_batched_job", to: "tests#shoryuken_batched_job"
  get "/cross_service_job", to: "tests#cross_service_job"
  root :to => "tests#index"
end
