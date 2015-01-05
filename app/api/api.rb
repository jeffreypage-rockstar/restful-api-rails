require_relative "validations/uuid"

class API < Grape::API
  VERSION = "1.0"
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  before do
    header["Access-Control-Allow-Origin"] = "*"
    header["Access-Control-Request-Method"] = "*"
    unless Rails.env.test?
      @log_start_t = Time.current
      method = request.env["REQUEST_METHOD"]
      path = request.env["REQUEST_PATH"]
      API.logger.info ""
      API.logger.info "Started #{method} \"#{path}\" at #{@log_start_t}"
      API.logger.info "   Parameters: #{params.to_hash.except("route_info")}"
    end
  end

  after do
    unless Rails.env.test?
      @log_end_t = Time.current
      total_runtime = ((@log_end_t -  @log_start_t) * 1000).round(1)
      db_runtime = (ActiveRecord::RuntimeRegistry.sql_runtime || 0).round(1)
      API.logger.info "Completed in #{total_runtime}ms "\
                      "(ActiveRecord: #{db_runtime}ms)"
    end
  end

  mount Hyper::V1::All
end
