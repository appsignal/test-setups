Rails.application.routes.draw do
  resources :workers do
    collection do
      get :queue
    end
  end
  mount Sidekiq::Web => "/sidekiq"

  resources :redis do
    collection do
      get :restful
      get :eval
    end
  end

  resources :requests do
    collection do
      get :perform_excon_get
      get :excon_get
      get :perform_excon_post
      post :excon_post
      get :perform_excon_put
      put :excon_put
      get :perform_excon_delete
      delete :excon_delete
      get :perform_excon_head
      get :perform_excon_options
      match "/excon_options" => "requests#excon_options", :via => :options
      get :perform_excon_trace
      match "/excon_trace" => "requests#excon_trace", :via => :trace
    end
  end

  root :to => "examples#index"
  get "/slow", to: "examples#slow"
  get "/error", to: "examples#error"
end
