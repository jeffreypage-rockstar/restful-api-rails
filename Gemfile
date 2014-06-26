source 'https://rubygems.org'
ruby "2.1.2"

gem 'rack'
gem 'grape'
gem 'grape-active_model_serializers'
gem 'grape-swagger'
gem 'encode_with_alphabet'
gem 'devise'
gem 'devise-async'
gem 'sidekiq'
gem 'pg'
gem 'foreman'
gem "koala", "~> 1.10.0rc"
gem 'kaminari'
gem 'api-pagination'
gem 'sentry-raven'
gem 'hashids'
gem 'acts_as_list'

group :api do
  gem 'activerecord', '~>4.1.1', require: 'active_record'
  gem 'actionview', '~>4.1.1', require: 'action_view'
  gem 'goliath'
  gem 'dotenv'
end

group :admin do
  gem 'rails', '4.1.1'
  gem 'thin'
  gem 'puma'
  gem 'sprockets', '~> 2.11.0'
  gem 'sass-rails', '~> 4.0.3'
  gem 'uglifier', '>= 1.3.0'
  gem 'jquery-rails'
  gem 'bootstrap-sass'
  gem 'bootstrap_form'
  gem 'sendgrid'
  gem 'sinatra', '>= 1.3.0', :require => nil #used by sidekiq monitoring
  gem 'rails_admin', github: 'inaka/rails_admin'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring'
  gem 'grape_doc'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
end
