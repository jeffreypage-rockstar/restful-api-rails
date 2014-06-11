require File.expand_path('../config/api_application', __FILE__)
require 'goliath'
require 'em-synchrony/activerecord'

class Server < Goliath::API

  def response(env)
    ApplicationServer.call(env)
  end

end