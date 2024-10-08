require "sidekiq/web"
require 'sinatra/base'

Appsignal.load(:sinatra)

class SinatraApp < Sinatra::Base
  get '/' do
    'Hello from Sinatra!'
  end

  get '/example' do
    'This is an example route in Sinatra.'
  end
end

Rails.application.routes.draw do
  mount SinatraApp, at: "/sinatra"

  resources :workers do
    collection do
      get :queue
    end
  end
  mount Sidekiq::Web => "/sidekiq"

  resources :chat_rooms
  resources :chat_messages

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
  get "/error_reporter", to: "examples#error_reporter"
  get "/queries", to: "examples#queries"
end
