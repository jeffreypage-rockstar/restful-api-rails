class Card < ActiveRecord::Base
  include Votable
  include Flaggable

  validates :name, :stack, :user, presence: true
  attr_readonly :score

  belongs_to :stack
  belongs_to :user
  has_many :images, -> { order("position ASC") },
           class_name: "CardImage",
           dependent: :destroy,
           inverse_of: :card
  accepts_nested_attributes_for :images
  has_many :comments, -> { order("created_at ASC") }

  scope :max_score, ->(score) { where("score <= ?", score) }
  scope :newest, -> { order("created_at DESC") }
  scope :popularity, -> { order("score DESC") }
end
