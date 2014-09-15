require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :fog
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: Rails.application.secrets.aws_access_key_id,
      aws_secret_access_key: Rails.application.secrets.aws_secret_access_key
      # :host                   => 's3.example.com',
      # :region                 => 'us-east-1'
    }
    config.fog_directory  = Rails.application.secrets.aws_s3_bucket
    config.fog_attributes = { "Cache-Control" => "max-age=315576000" }
  end
end
