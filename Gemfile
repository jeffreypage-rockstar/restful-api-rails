source 'https://rubygems.org'
ruby "2.1.2"

gem 'rack'
gem 'grape'
gem 'rails', '4.1.1'
gem 'encode_with_alphabet'
gem 'racksh'
gem 'thin'
gem 'sprockets', '~> 2.11.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'devise'
gem 'pundit'
gem 'sendgrid'
gem 'pg'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :production do
  gem 'puma'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
end