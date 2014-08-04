module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable
    has_many :up_votes, -> { up_votes }, class_name: "Vote", as: :votable
  end

  # if a user vote exists, update it. if not, creates a new vote
  def vote_by!(user, kind: :up)
    vote = votes.find_or_initialize_by(user_id: user.id)
    vote.kind = kind
    vote.save!
    log_vote(user, kind)
    vote
  end

  def log_vote(user, kind)
    return unless respond_to? :create_activity
    create_activity("#{kind}_vote", owner: user)
  end

  def update_scores!
    self.down_score = votes.down_votes.sum(:weight)
    self.up_score = votes.up_votes.sum(:weight)
    self.score = up_score - down_score
    save(validate: false)
  end
end
