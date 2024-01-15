Rails.application.routes.draw do
  root :to => "examples#index"
  get "/slow", to: "examples#slow"
  get "/error", to: "examples#error"
  resources :items
end
