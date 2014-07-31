class Vote < ActiveRecord::Base
  KINDS = %w(up down)

  validates :votable, :user, presence: true

  validates :user_id, uniqueness: { scope: :votable_id }

  belongs_to :votable, polymorphic: true
  belongs_to :user

  before_save :store_flag_change
  after_save :update_score

  scope :up_votes, -> { where(flag: true) }
  scope :down_votes, -> { where(flag: false) }
  scope :recent, -> { order("created_at DESC") }

  def up_vote?
    flag?
  end

  def down_vote?
    !flag?
  end

  def kind
    up_vote? ? "up" : "down"
  end

  def kind=(value)
    return unless KINDS.include?(value.to_s)
    self.flag = value.to_s == "up"
  end

  def vote_score
    up_vote? ? weight : (weight * -1)
  end

  private # ===========================================================

  # if flag column is changed, the parent score needs to remove the old weight
  # and add the new one
  def score_change
    # result = vote_score
    # @flag_changed ? (result * 2) : result

    up_score_change - down_score_change
  end

  def up_score_change
    if up_vote?
      weight
    else
      @flag_changed ? weight * -1 : 0
    end
  end

  def down_score_change
    if up_vote?
      @flag_changed ? weight * -1 : 0
    else
      weight
    end
  end

  def update_score
    return unless votable.respond_to?("score=")
    votable.class.update_counters(votable.id, score: score_change,
                                              up_score: up_score_change,
                                              down_score: down_score_change)
    if votable.respond_to? :user_id
      User.update_counters(votable.user_id, score: score_change)
    end
  end

  # keep a flag_changed state to know when flag is changed in a persisted vote
  def store_flag_change
    @flag_changed = !new_record? && changes[:flag].try(:many?)
    true
  end
end
