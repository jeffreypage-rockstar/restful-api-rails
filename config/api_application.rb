$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../..", __FILE__)

require "config/boot"
Bundler.require :default, :api
require "kaminari/grape"
require "grape/application"

require "dotenv"
Dotenv.load

I18n.load_path << File.expand_path("../locales/en.yml", __FILE__)

ActiveSupport::Cache.lookup_store :redis_store

module Hyper
  class Application < Grape::Application
    config.root = File.expand_path("../..", __FILE__)
    config.load_paths += Dir["app/**/*"]
    # config.base_path  = "http://localhost:9292"
    config.filter_parameters = []
    if ENV["LOGSTASH_ENABLED"] == "1"
      config.logger = LogStashLogger.new(type: :udp,
                                         host: "127.0.0.1",
                                         port: 9125)
      puts "*** Using LogStashLogger ***"
    end
  end
end

Hyper::Application.new
