require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :admins
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  root to: "visitors#index"
  devise_for :users
  get "/c/:id" => "visitors#card", as: :card

  mount API => "/api"
  authenticate :admin do
    mount Sidekiq::Web => "/sidekiq"
  end
end
