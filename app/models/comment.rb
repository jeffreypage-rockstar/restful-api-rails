class Comment < ActiveRecord::Base
  include Votable
  include Flaggable
  include PublicActivity::Model
  tracked owner: :user, recipient: :card
  validates :user, :card, presence: true

  belongs_to :user
  belongs_to :card, counter_cache: true, touch: true
  belongs_to :replying, class_name: "Comment"

  store_accessor :mentions

  before_save :extract_mentions, :fix_replying_id

  scope :max_score, ->(score) { where("score <= ?", score) }
  scope :newest, -> { order("created_at DESC") }
  scope :oldest, -> { order("created_at ASC") }

  def mentions
    self[:mentions] || {}
  end

  def self.popularity
    select("*, ci_lower_bound(up_score, down_score) as rank").
      order("rank DESC, created_at ASC")
  end

  def notification_image_url
    card.notification_image_url
  end

  private # ===============================================================

  def extract_mentions
    usernames = body.to_s.scan(/@([[:alnum:].]+)/i).flatten
    users = User.where(username: usernames)
    self.mentions = users.each_with_object({}) do |user, hash|
      hash[user.username] = user.id
    end
  end

  def fix_replying_id
    self.replying_id = nil if replying_id.blank?
  end
end
