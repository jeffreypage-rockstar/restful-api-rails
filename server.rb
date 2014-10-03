require File.expand_path("../config/api_application", __FILE__)
require "app/api/api"
require "goliath"
require "em-synchrony/activerecord"

API_SERVER = Rack::Builder.new do
  use Rack::Attack
  use Rack::Static, urls: %w(/docs/), root: "public/api", index: "index.html"
  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  map "/" do
    run API
  end
end

# goliath server instance
class Server < Goliath::API
  def response(env)
    API_SERVER.call(env)
  end
end
