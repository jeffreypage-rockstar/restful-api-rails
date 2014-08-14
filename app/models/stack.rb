require "smarter_csv"

class Stack < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user

  validates :name, :user_id, presence: true

  validates :name, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-zA-Z0-9_]*\z/ }

  belongs_to :user
  has_many :cards, dependent: :restrict_with_exception
  has_many :subscriptions

  scope :recent, -> { order("created_at DESC") }
  scope :recent_active, -> { order("updated_at DESC") }
  scope :popular, -> { order("subscriptions_count ASC") }

  before_validation :remove_hashtag

  def display_name
    "##{name}"
  end

  def self.trending(user_id)
    subscribed_sql = "NOT stacks.id IN (select stack_id from "\
                     "subscriptions where user_id = ?)"
    where.not(user_id: user_id).where(subscribed_sql, user_id).recent_active
  end

  def user
    return nil if user_id.blank?
    super
  end

  def self.import_csv(csv_file)
    SmarterCSV.process(csv_file).map do |stack_data|
      Stack.new(stack_data)
    end.select(&:save)
  end

  private # ================================

  def remove_hashtag
    self.name = name.to_s.gsub(/^\#/, "")
  end
end
