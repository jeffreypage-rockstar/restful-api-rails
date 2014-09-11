require "public_activity"

PublicActivity::Activity.class_eval do
  validates :key, presence: true

  after_save :trigger_notification

  private

  def trigger_notification
    return if notified?
    API.logger.info "===> trigger_notification for #{[id, key]}"
    Notifier.notify_async(id, key) || update_attribute(:notified, true)
  end
end
