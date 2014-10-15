require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :admins
  namespace :admin do
    get "/users_chart" => "charts#users", as: :users_chart
  end
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  if Rails.env.production?
    root to: redirect("http://hyper.is")
  else
    root to: "visitors#index"
  end
  devise_for :users
  get "/c/:id" => "visitors#card", as: :card
  get "/s/:id" => "visitors#page", as: :static

  mount API => "/api"
  authenticate :admin do
    mount Sidekiq::Web => "/sidekiq"
    mount PgHero::Engine => "/pghero"
  end
end
