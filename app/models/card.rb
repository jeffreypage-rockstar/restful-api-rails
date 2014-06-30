class Card < ActiveRecord::Base
  validates :name, :stack, :user, presence: true

  belongs_to :stack
  belongs_to :user
  has_many :images, -> { order("position ASC") },
           class_name: "CardImage",
           dependent: :destroy,
           inverse_of: :card
  accepts_nested_attributes_for :images
  has_many :votes, as: :votable

  scope :recent, -> { order("created_at DESC") }
  
  def vote_by!(user, up_vote: true)
    vote = self.votes.find_or_initialize_by(user_id: user.id)
    vote.flag = up_vote
    vote.save!
  end
end
