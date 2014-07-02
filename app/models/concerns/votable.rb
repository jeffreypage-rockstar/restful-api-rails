module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable
  end

  # if a user vote exists, update it. if not, creates a new vote
  def vote_by!(user, kind: :up)
    vote = votes.find_or_initialize_by(user_id: user.id)
    vote.kind = kind
    vote.save!
    vote
  end
end
