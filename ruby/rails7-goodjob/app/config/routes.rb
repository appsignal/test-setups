Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :jobs do
    collection do
      get :slow
      get :error
    end
  end

  root :to => "examples#index"
  get "/slow", to: "examples#slow"
  get "/error", to: "examples#error"
  get "/streaming-error", to: "examples#streaming_error_in_body"
end
