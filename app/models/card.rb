class Card < ActiveRecord::Base
  validates :name, :stack, :user, presence: true
  attr_readonly :score

  belongs_to :stack
  belongs_to :user
  has_many :images, -> { order("position ASC") },
           class_name: "CardImage",
           dependent: :destroy,
           inverse_of: :card
  accepts_nested_attributes_for :images
  has_many :votes, as: :votable

  scope :max_score, ->(score) { where("score <= ?", score) }
  scope :newest, -> { order("created_at DESC") }
  scope :popularity, -> { order("score DESC") }

  # if a user vote exists, update it. if not, creates a new vote
  def vote_by!(user, up_vote: true)
    vote = votes.find_or_initialize_by(user_id: user.id)
    vote.flag = up_vote
    vote.save!
    vote
  end
end
