# encoding: utf-8

class CardImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{model.id}"
  end

  process resize_to_fit: [640, 10000] # default size is retina thumbnail

  version :thumbnail do
    process resize_to_fit: [320, 10000]
  end
end
