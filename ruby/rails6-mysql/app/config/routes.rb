Rails.application.routes.draw do
  get "/slow", to: "tests#slow"
  get "/error", to: "tests#error"
  get "/streaming-error", to: "tests#streaming_error_in_body"

  resources :posts, :except => %i[edit update destroy]
end
