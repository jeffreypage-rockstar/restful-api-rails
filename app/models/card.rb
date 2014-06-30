class Card < ActiveRecord::Base
  validates :name, :stack, :user, presence: true

  belongs_to :stack
  belongs_to :user
  has_many :images, -> { order("position ASC") },
           class_name: "CardImage",
           dependent: :destroy,
           inverse_of: :card
  accepts_nested_attributes_for :images

  scope :recent, -> { order("created_at DESC") }
end
