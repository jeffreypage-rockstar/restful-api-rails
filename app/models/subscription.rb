class Subscription < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user, recipient: :stack

  validates :user_id, :stack_id, presence: true
  validates_uniqueness_of :stack_id, scope: :user_id, allow_blank: true,
                                     if: Proc.new { |u| u.user_id.present? }

  belongs_to :user
  belongs_to :stack, counter_cache: true

  scope :recent, -> { order("created_at DESC") }
  scope :oldest, -> { order("created_at ASC") }

  MAX_USER_SUBSCRIPTIONS = 50

  after_create :check_max_user_subscriptions

  private # ================================================

  def check_max_user_subscriptions
    size = Subscription.where(user_id: user_id).count - MAX_USER_SUBSCRIPTIONS
    return true if size <= 0
    Subscription.where(user_id: user_id).oldest.limit(size).map(&:destroy)
  end
end
