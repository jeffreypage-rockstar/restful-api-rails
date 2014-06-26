class CardImage < ActiveRecord::Base
  validates :card_id, :image_url, presence: true

  belongs_to :card
  acts_as_list scope: :card
end
