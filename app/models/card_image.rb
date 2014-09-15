class CardImage < ActiveRecord::Base
  validates :card, :original_image_url, presence: true
  validates :original_image_url, url: true

  belongs_to :card, inverse_of: :images
  acts_as_list scope: :card
  mount_uploader :image, CardImageUploader

  before_validation :fix_original_image_url
  after_save :process_image

  URL_REGEX = /^(https?:\/)(\w.*)/

  def image_url
    original_image_url
  end

  def image_url=(value)
    self.original_image_url = value
  end

  def retina_thumbnail_url
    image.try(:url)
  end

  def thumbnail_url
    return nil unless image
    image.thumbnail.try(:url)
  end

  private

  def fix_original_image_url
    self.original_image_url = "#{$1}/#{$2}" if image_url.to_s =~ URL_REGEX
  end

  def process_image
    return true if !original_image_url_changed? || image_processing
    ImageProcessWorker.perform_async(id, original_image_url)
    update_column :image_processing, true
  end
end
