class API < Grape::API
  format :json
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
  mount Hyper::Stacks
  mount Hyper::Subscriptions

  base_path_proc = Proc.new do |r|
    if Rails.env.development?
      "http#{r.base_url}"
    else
      "http://#{r.host}"
    end
  end
  add_swagger_documentation mount_path: 'api_docs',
                            api_version: 'v1',
                            hide_documentation_path: true,
                            hide_format: true,
                            base_path: base_path_proc
end
