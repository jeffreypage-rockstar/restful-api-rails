require 'public_activity'

PublicActivity::Activity.class_eval do
  before_save :trigger_notification

  private

  def trigger_notification
    return if notified? || key.blank?
    notifier_name = key.gsub(/\W/, "_").camelize.to_sym
    if Notifier.constants.include? notifier_name
      notifier = Notifier.const_get(notifier_name).new
      notifier.perform_async(self.id)
    else
      self.notified = true
    end
  end
end