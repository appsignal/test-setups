Rails.application.routes.draw do
  get '/', to: redirect('/items')
  resources :items
end
