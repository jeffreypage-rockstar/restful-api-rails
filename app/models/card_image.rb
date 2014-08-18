class CardImage < ActiveRecord::Base
  validates :card, presence: true
  validates :image_url, url: true

  belongs_to :card, inverse_of: :images
  acts_as_list scope: :card

  before_validation :fix_image_url

  private

  def fix_image_url
    self.image_url = "#{$1}/#{$2}" if image_url.to_s =~ /^(https?:\/)(\w.*)/
  end
end
