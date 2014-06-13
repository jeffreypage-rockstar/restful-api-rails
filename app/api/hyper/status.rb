module Hyper
  class Status < Base
    desc 'Returns the status of the API'
    get '/status' do
      { status: 'ok', domain: Rails.application.secrets.domain_name }
    end
  end
end

