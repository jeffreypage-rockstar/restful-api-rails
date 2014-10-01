require "erb"
require "active_support/core_ext"

module Grape
  mattr_accessor :application

  class Application
    include ActiveSupport::Configurable

    LOGGER_LEVELS = {
      "development" => Logger::DEBUG,
      "staging"     => Logger::DEBUG,
      "production"  => Logger::INFO
    }

    # default config
    config.load_paths = []
    config.env = ActiveSupport::StringInquirer.new(
                  ENV["RACK_ENV"] || "development"
                 )
    config.root = File.dirname(__FILE__)

    def secrets
      @secrets ||= begin
        secrets = ActiveSupport::OrderedOptions.new
        secrets_file = File.read(File.expand_path("config/secrets.yml",
                                                  config.root))
        all_secrets = YAML.load(ERB.new(secrets_file).result)
        env_secrets = all_secrets[config.env]
        secrets.merge!(env_secrets.symbolize_keys) if env_secrets
        secrets
      end
    end

    def set_dependency_paths
      config.load_paths.each do |path|
        ActiveSupport::Dependencies.autoload_paths << path
      end
    end

    def connect_database
      config_file = File.read(File.expand_path("config/database.yml",
                                               config.root))
      all_db_config = YAML.load(ERB.new(config_file).result)
      db_config = all_db_config[config.env]
      ActiveRecord::Base.default_timezone = :utc
      ActiveRecord::Base.establish_connection(db_config)
    end

    def load_initializers
      Dir[File.expand_path("config/initializers/*.rb", config.root)].each do |f|
        require f
      end
    end

    def initialize_logger
      Grape::API.logger = config.logger if config.logger
      ActiveRecord::Base.logger = @logger = Grape::API.logger
      @logger.level = logger_level
    end

    def logger
      @logger
    end

    def logger=(logger)
      @logger = logger
      @logger.level = logger_level
    end

    def logger_level
      LOGGER_LEVELS[config.env] || Logger::WARN
    end

    def initialize
      Grape.application = self
      Rails.application ||= self if defined? Rails
      set_dependency_paths
      initialize_logger
      connect_database
      load_initializers
    end
  end
end
