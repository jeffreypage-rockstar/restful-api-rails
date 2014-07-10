require "raven"
require "raven/sidekiq"

if Rails.application.secrets.dsn
  Raven.configure do |config|
    config.dsn = Rails.application.secrets.dsn
    # config.environments = %w( default )
    # config.async = lambda do |event|
    #   Thread.new { Raven.send(event) }
    # end
  end
end
