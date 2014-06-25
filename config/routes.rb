require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users
  resources :users

  mount API => '/api'
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end
