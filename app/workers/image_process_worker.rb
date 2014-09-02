# A sidekiq worker to process uploaded images with carrierwave
class ImageProcessWorker
  include Sidekiq::Worker

  def perform(card_image_id, original_image_url)
    CardImage.find(card_image_id).tap do |card_image|
      card_image.remote_image_url = original_image_url
      card_image.save!
      card_image.update_column :image_processing, false
    end
  end
end
