class CardImage < ActiveRecord::Base
  validates :card, :image_url, presence: true

  belongs_to :card, inverse_of: :images
  acts_as_list scope: :card
end
