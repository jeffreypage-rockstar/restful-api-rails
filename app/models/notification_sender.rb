class NotificationSender < ActiveRecord::Base
  validates :notification_id, :user_id, :username, presence: true
  validates :user_id, uniqueness: { scope: :notification_id }

  belongs_to :notification, counter_cache: :senders_count
  belongs_to :user

  def self.[](username)
    where(username: username).first
  end

  def self.mass_insert_user(user, notification_ids)
    missing_ids = notification_ids - NotificationSender.where(
                                       notification_id: notification_ids,
                                       user_id: user.id
                                     ).pluck(:notification_id)

    senders = missing_ids.map do |nid|
      NotificationSender.new(
        notification_id: nid,
        user_id: user.id,
        username: user.username
      )
    end
    NotificationSender.import senders, validate: false
    Notification.increment_counter(:senders_count, missing_ids)
  end
end
