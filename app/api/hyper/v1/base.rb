module Hyper
  module V1
    class EmptyBodyException < StandardError; end

    class Base < Grape::API
      def self.inherited(subclass) # rubocop:disable PerceivedComplexity
        super
        subclass.instance_eval do
          version "v1", using: :accept_version_header
          format :json

          helpers do
            def auth_credentials
              credentials = { id: nil, access_token: "0" }
              if request.env["HTTP_AUTHORIZATION"]
                auth_header = request.env["HTTP_AUTHORIZATION"].split(" ")

                if auth_header[0] == "Basic" && auth_header[1] != ""
                  id, token = Base64.decode64(auth_header[1]).split(":")
                  credentials[:id] = id if id =~ Validation::Uuid::UUID_REGEX
                  credentials[:access_token] = token unless token.blank?
                end
              end

              credentials
            end

            def permitted_params
              declared(params, include_missing: false)
            end

            def logger
              API.logger
            end

            def current_user
              @current_user ||= current_device.try(:user)
            end

            def current_device
              @current_device ||= begin
                Device.where(auth_credentials).includes(:user).first
              end
            end

            def authenticate!
              current_user || auth_error!
            end

            def auth_error!
              error!("401 Unauthenticated", 401,
                     "WWW-Authenticate" => "Basic realm=\"Hyper\""
                    )
            end

            def authorize!(action, model)
              ::Ability.new(current_user).authorize!(action, model)
            end

            def forbidden!(msg = nil)
              error!(msg || "403 Forbidden", 403)
            end

            def validate_record!(record)
              if record.errors.any?
                raise ActiveRecord::RecordInvalid.new(record)
              else
                record
              end
            end

            def empty_body!
              raise EmptyBodyException
            end

          end

          rescue_from ActiveRecord::RecordNotFound do |e|
            message = e.message.gsub(/\s*\[.*\Z/, "")
            Rack::Response.new(
              [{
                status: 404,
                status_code: "not_found",
                error: message,
              }.to_json],
              404,
              "Content-Type" => "application/json"
            )
          end

          rescue_from ActiveRecord::RecordNotUnique do |e|
            message = e.message.downcase.capitalize
            Rack::Response.new(
              [{
                status: 409,
                status_code: "conflict",
                error: message,
                errors: e.record.try(:errors)
              }.to_json],
              409,
              "Content-Type" => "application/json"
            )
          end

          # ActiveRecord::RecordInvalid is raise whenever a model validation is
          # failed. ActiveRecord::RecordNotUnique is raised only if
          # validate:false is provided to record.save method
          rescue_from ActiveRecord::RecordInvalid do |e|
            message = e.message.downcase.capitalize
            if message =~ /has already been taken$/
              status = 409
              code = "conflict"
            else
              status = 422
              code = "invalid_resource"
            end
            Rack::Response.new(
              [{
                status: status,
                status_code: code,
                error: message,
                errors: e.record.try(:errors)
              }.to_json],
              status,
              "Content-Type" => "application/json"
            )
          end

          rescue_from CanCan::AccessDenied do |e|
            Rack::Response.new({
              status: 403,
              error: e.message
            }.to_json, 403)
          end

          rescue_from EmptyBodyException do
            Rack::Response.new([""], 204, "Content-Type" => "text/plain")
          end

          rescue_from ArgumentError do |e|
            Rack::Response.new({
              status: 400,
              error: e.message
            }.to_json, 400)
          end

          rescue_from Grape::Exceptions::ValidationErrors do |e|
            Rack::Response.new({
              status: e.status,
              error: e.message,
              errors: e.errors
            }.to_json, e.status)
          end

          # global exception handler, used for error notifications
          rescue_from :all do |e|
            if Rails.env.development? || Rails.env.test?
              raise e
            else
              Raven.capture_exception(e)
              error_response(message: "Internal server error", status: 500)
            end
          end
        end
      end

      default_format :json
    end
  end
end
