require_relative "validations/uuid"

class API < Grape::API
  VERSION = "1.0"
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  before do
    header["Access-Control-Allow-Origin"] = "*"
    header["Access-Control-Request-Method"] = "*"
    unless Rails.env.test?
      API.logger.info [request.env["REQUEST_METHOD"],
                       request.env["REQUEST_PATH"]]
      API.logger.info request.body.read
    end
  end

  mount Hyper::V1::All
end
