require "smarter_csv"

class Stack < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user

  validates :name, :user, presence: true

  validates :name, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-zA-Z0-9_]*\z/ }

  belongs_to :user
  has_many :cards, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :destroy
  has_many :stats, class_name: "StackStats"

  scope :recent, -> { order("created_at DESC") }
  scope :recent_active, -> { order("updated_at DESC") }
  scope :most_popular, -> { order("subscriptions_count DESC") }

  before_validation :remove_hashtag

  def display_name
    "##{name}"
  end

  def self.trending(user_id)
    not_subscribed_by(user_id).where.not(user_id: user_id).recent_active
  end

  def self.popular(user_id)
    not_subscribed_by(user_id).where.not(user_id: user_id).most_popular
  end

  def self.not_subscribed_by(user_id)
    sql = "stacks.id IN (select stack_id from subscriptions where user_id = ?)"
    where.not(sql, user_id)
  end

  def user
    return nil if user_id.blank?
    super
  end

  def stats_count
    @stats_count ||= stats.count
  end

  def cards_count
    @cards_count ||= cards.count
  end

  def self.import_csv(csv_file)
    SmarterCSV.process(csv_file).map do |stack_data|
      Stack.new(stack_data)
    end.select(&:save)
  end

  def notification_image_url
    cards.newest.first.try(:notification_image_url)
  end

  private # ================================

  def remove_hashtag
    self.name = name.to_s.gsub(/^\#/, "")
  end
end
