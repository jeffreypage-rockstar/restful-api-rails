module Hyper
  class Base < Grape::API
    def self.inherited(subclass)
      super
      subclass.instance_eval do
        version 'v1', using: :accept_version_header
        format :json

        helpers do
          def auth_credentials
            credentials = { id: '0', access_token: '0' }
            if request.env['HTTP_AUTHORIZATION']
              auth_header = request.env['HTTP_AUTHORIZATION'].split(' ')

              if auth_header[0] == 'Basic' && auth_header[1] != ''
                id, token = Base64.decode64(auth_header[1]).split(':')
                credentials[:id] = id unless id.blank?
                credentials[:access_token] = token unless token.blank?
              end
            end

            credentials
          end

          def current_user
            @current_user ||= begin
              Device.where(auth_credentials).includes(:user).first.try(:user)
            end
          end

          def authenticate!
            auth_error! unless current_user
          end

          def auth_error!
            error!('401 Unauthenticated', 401)
          end

        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          message = e.message.gsub(/\s*\[.*\Z/, '')
          Rack::Response.new(
            [{
              status: 404,
              status_code: 'not_found',
              error: message
            }.to_json],
            404,
            'Content-Type' => 'application/json'
          )
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          message = e.message.downcase.capitalize
          Rack::Response.new(
            [{
              status: 403,
              status_code: 'record_invalid',
              error: message
            }.to_json],
            403,
            'Content-Type' => 'application/json'
          )
        end
      end
    end

    default_format :json
  end
end
