env = (ENV["RACK_ENV"] || :development)

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../../lib")
$LOAD_PATH.unshift File.dirname(File.expand_path("../..", __FILE__))
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..")

require "grape"
require "warden"
require "boot"
require "kaminari/grape"

Bundler.require :default, :api
require "erb"
require "active_support/core_ext"

require "dotenv"
Dotenv.load

I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

module Application
  include ActiveSupport::Configurable

  def self.secrets
    @secrets ||= begin
      secrets = ActiveSupport::OrderedOptions.new
      all_secrets = YAML.load(ERB.new(File.read("config/secrets.yml")).result)
      env_secrets = all_secrets[Application.config.env]
      secrets.merge!(env_secrets.symbolize_keys) if env_secrets
      secrets
    end
  end
end

Application.configure do |config|
  config.root       = File.dirname(__FILE__)
  config.env        = ActiveSupport::StringInquirer.new(env.to_s)
  # config.base_path  = "http://localhost:9292"
  config.filter_parameters = []
end

Rails.application ||= Application

# database config
all_db_config = YAML.load(ERB.new(File.read("config/database.yml")).result)
db_config = all_db_config[Application.config.env]
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection(db_config)

Dir[File.expand_path("../../initializers/*.rb", __FILE__)].each do |f|
  require f
end

# devise initialization
Devise.secret_key ||= Application.secrets.secret_key_base
Devise.token_generator ||= Devise::TokenGenerator.new(
                            Devise::CachingKeyGenerator.new(
                              Devise::KeyGenerator.new(Devise.secret_key)
                            )
                          )
