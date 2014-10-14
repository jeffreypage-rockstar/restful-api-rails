Sidekiq.configure_server do |config|

  if defined?(ActiveRecord::Base)
    sidekiq_pool = ENV["SIDEKIQ_DB_POOL"] || 25

    Rails.logger.debug("Setting custom connection pool size of "\
                       "#{sidekiq_pool} for Sidekiq Server")
    config = Rails.application.config.database_configuration[Rails.env]
    config["reaping_frequency"] = ENV["DB_REAP_FREQ"] || 10 # seconds
    config["pool"]              = sidekiq_pool
    ActiveRecord::Base.establish_connection(config)
    current_pool_size = ActiveRecord::Base.connection.pool.
                                           instance_variable_get("@size")
    Rails.logger.info("Connection pool size for Sidekiq Server is now: "\
                      "#{current_pool_size}")
  end
end
