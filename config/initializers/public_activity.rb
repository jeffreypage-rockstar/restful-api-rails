require "public_activity"

PublicActivity::Activity.class_eval do
  validates :key, presence: true

  after_commit :trigger_notification

  private

  def trigger_notification
    return if notified? || !persisted?
    Notifier.notify_async(id, key) || update_column(:notified, true)
  end
end
