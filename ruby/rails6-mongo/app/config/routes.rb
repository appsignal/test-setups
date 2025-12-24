Rails.application.routes.draw do
  root "posts#index"

  get "/slow", to: "tests#slow"
  get "/error", to: "tests#error"
  get 'healthy' => 'health_check#show', as: :health_check

  resources :posts, :except => %i[edit update destroy]
end
