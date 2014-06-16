class API < Grape::API
  format    :json
  formatter :json, Grape::Formatter::ActiveModelSerializers
  
  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  mount Hyper::Status
  mount Hyper::Login
  mount Hyper::Auth
  mount Hyper::Account
  mount Hyper::Devices
end