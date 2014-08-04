class CardImage < ActiveRecord::Base
  validates :card, presence: true
  validates :image_url, url: true

  belongs_to :card, inverse_of: :images
  acts_as_list scope: :card
end
