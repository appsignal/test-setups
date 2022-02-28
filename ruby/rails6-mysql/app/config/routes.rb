Rails.application.routes.draw do
  get "/slow", to: "tests#slow"
  get "/error", to: "tests#error"

  resources :posts, :except => %i[edit update destroy]
end
