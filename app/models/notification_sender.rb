class NotificationSender < ActiveRecord::Base
  validates :notification_id, :user_id, :username, presence: true
  validates :user_id, uniqueness: { scope: :notification_id }

  belongs_to :notification, counter_cache: :senders_count

  def self.[](username)
    where(username: username).first
  end
end
