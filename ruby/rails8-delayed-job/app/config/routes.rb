Rails.application.routes.draw do
  root to: "examples#index"
  resources :jobs do
    collection do
      get :queue
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "/slow", to: "examples#slow"
  get "/error", to: "examples#error"
  get "/error_cause", to: "examples#error_cause"
  get "/error_reporter", to: "examples#error_reporter"
  get "/custom_error", to: "examples#custom_error"

  resources :posts
end
