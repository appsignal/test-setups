require "sidekiq/web"

Rails.application.routes.draw do
  root :to => "examples#index"
  resources :workers do
    collection do
      get :queue
    end
  end
  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check

  get "/slow", to: "examples#slow"
  get "/error", to: "examples#error"
  get "/error_cause", to: "examples#error_cause"
  get "/error_reporter", to: "examples#error_reporter"
  get "/custom_error", to: "examples#custom_error"
end
