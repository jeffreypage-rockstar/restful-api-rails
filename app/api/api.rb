require_relative "validations/uuid"

class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  before do
    header["Access-Control-Allow-Origin"] = "*"
    header["Access-Control-Request-Method"] = "*"
    unless Rails.env.test?
      log = request.env["rack.logger"] || logger
      log.info [request.env["REQUEST_METHOD"], request.env["REQUEST_PATH"]]
      log.info request.body.read
    end
  end

  mount Hyper::Status
  mount Hyper::Login
  mount Hyper::Auth
  mount Hyper::Account
  mount Hyper::Devices
  mount Hyper::Stacks
  mount Hyper::Subscriptions
  mount Hyper::Cards
  mount Hyper::Comments
  mount Hyper::Flags
  mount Hyper::SuggestedImages
  mount Hyper::Networks
  mount Hyper::Reputations
  mount Hyper::Notifications

  base_path_proc = Proc.new do |r|
    if Rails.env.development?
      "http#{r.base_url}"
    else
      "http://#{r.host}"
    end
  end
  add_swagger_documentation mount_path: "api_docs",
                            api_version: "v1",
                            hide_documentation_path: true,
                            hide_format: true,
                            base_path: base_path_proc
end
