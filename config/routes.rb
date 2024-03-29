require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :admins
  namespace :admin do
    get "/users_chart" => "charts#users", as: :users_chart
  end
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  root to: "visitors#index"
  devise_for :users, controllers: { registrations: :registrations }

  get "/home"  => "visitors#index", as: :home
  get "/c/:id" => "visitors#card", as: :card
  get "/s/:id" => "visitors#page", as: :static

  mount API => "/api"
  authenticate :admin do
    mount Sidekiq::Web => "/sidekiq"
    mount PgHero::Engine => "/pghero"
  end
end
