require "public_activity"

PublicActivity::Activity.class_eval do
  after_save :trigger_notification

  private

  def trigger_notification
    return if notified? || key.blank?
    Notifier.notify_async(id, key) || self.update_attribute(:notified, true)
  end
end
