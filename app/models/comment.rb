class Comment < ActiveRecord::Base
  include Votable
  validates :user, :card, presence: true

  belongs_to :user
  belongs_to :card
  belongs_to :replying, class_name: "Card"

  store_accessor :mentions

  before_save :extract_mentions

  scope :max_score, ->(score) { where("score <= ?", score) }
  scope :newest, -> { order("created_at DESC") }
  scope :popularity, -> { order("score DESC") }

  private # ===============================================================

  def extract_mentions
    usernames = body.to_s.scan(/@([[:alnum:].]+)/i).flatten
    users = User.where(username: usernames)
    self.mentions = users.inject({}) do |hash, user|
      hash[user.username] = user.id
      hash
    end
  end
end
