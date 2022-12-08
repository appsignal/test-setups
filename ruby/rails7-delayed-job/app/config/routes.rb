Rails.application.routes.draw do
  resources :jobs

  get :slow, :to => "examples#slow"
  get :error, :to => "examples#error"

  root :to => "examples#index"
end
