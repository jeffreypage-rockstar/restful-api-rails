class Notification < ActiveRecord::Base
  validates :user, :subject, :action, presence: true
  store_accessor :senders

  belongs_to :user
  belongs_to :subject, polymorphic: true

  scope :unread, -> { where(read_at: nil).order(created_at: :desc) }
  scope :unseen, -> { where(seen_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mask_as_read!
    self.read_at = Time.now.utc
    save
  end

  def read?
    read_at.present?
  end

  def seen?
    seen_at.present?
  end

  def add_sender(sender_user)
    self.senders ||= {}
    self.senders[sender_user.username] = sender_user.id
  end

  def senders_count
    (self.senders || {}).keys.size
  end

  def send!
    # TODO: trigger a push notification if necessary
    self.sent_at = Time.now.utc
    save
  end

  def sent?
    sent_at.present?
  end

  # CLASS METHODS =======================

  def self.mark_all_as_read(user_id, before_notification)
    unread.where(user_id: user_id).
           where("created_at <= ?", before_notification.created_at).
           update_all(read_at: Time.now.utc)
  end

  def self.mark_all_as_seen(user_id, before_notification)
    unseen.where(user_id: user_id).
           where("created_at <= ?", before_notification.created_at).
           update_all(seen_at: Time.now.utc)
  end
end
