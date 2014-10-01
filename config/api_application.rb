$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../..", __FILE__)

require "config/boot"
Bundler.require :default, :api
require "kaminari/grape"
require "grape/application"

require "dotenv"
Dotenv.load

I18n.load_path << File.expand_path("../locales/en.yml", __FILE__)

module Hyper
  class Application < Grape::Application
    config.root = File.expand_path("../..", __FILE__)
    config.load_paths += Dir["app/**/*"]
    # config.base_path  = "http://localhost:9292"
    config.filter_parameters = []
  end
end

Hyper::Application.new
