require File.expand_path('../config/api_application', __FILE__)
require 'goliath'
require 'em-synchrony/activerecord'

# goliath server instance
class Server < Goliath::API
  def response(env)
    ApplicationServer.call(env)
  end
end
