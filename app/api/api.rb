class API < Grape::API
  format :json

  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  mount Hyper::Base
  mount Hyper::Status
end

