Rails.application.routes.draw do
  resources :workers do
    collection do
      get :queue
    end
  end
  mount Sidekiq::Web => "/sidekiq"
  root :to => "workers#index"
end
