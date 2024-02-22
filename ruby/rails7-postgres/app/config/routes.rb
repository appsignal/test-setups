Rails.application.routes.draw do
  root :to => "examples#index"
  get "/slow", to: "examples#slow"
  get "/error", to: "examples#error"
  get "/streaming/slow", to: "examples#streaming_slow"
  get "/streaming/error", to: "examples#streaming_error_in_body"
  resources :items
end
