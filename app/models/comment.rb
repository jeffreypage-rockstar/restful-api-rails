class Comment < ActiveRecord::Base
  include Votable
  include Flaggable
  include PublicActivity::Model
  tracked owner: :user, recipient: :card
  validates :user, :card, presence: true

  belongs_to :user
  belongs_to :card, counter_cache: true
  belongs_to :replying, class_name: "Comment"

  store_accessor :mentions

  before_save :extract_mentions

  scope :max_score, ->(score) { where("score <= ?", score) }
  scope :newest, -> { order("created_at DESC") }
  scope :oldest, -> { order("created_at ASC") }
  scope :popularity, -> { order("score DESC") }

  after_save :log_reply, on: :create

  def mentions
    read_attribute(:mentions) || {}
  end

  private # ===============================================================

  def extract_mentions
    usernames = body.to_s.scan(/@([[:alnum:].]+)/i).flatten
    users = User.where(username: usernames)
    self.mentions = users.each_with_object({}) do |user, hash|
      hash[user.username] = user.id
    end
  end

  def log_reply
    return if replying.nil?
    replying.create_activity :reply, owner: user, recipient: self
  end
end
