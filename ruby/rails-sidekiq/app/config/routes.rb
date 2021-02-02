Rails.application.routes.draw do
  resources :workers do
    collection do
      get :queue
    end
  end
  mount Sidekiq::Web => "/sidekiq" # mount Sidekiq::Web in your Rails app
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
