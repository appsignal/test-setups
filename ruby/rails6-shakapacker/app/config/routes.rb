Rails.application.routes.draw do
  get "/slow" => "pages#slow"
  get "/error" => "pages#error"
  root to: "pages#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
