module Notifier
  class Base
    include Sidekiq::Worker

    def notifications
      raise "notifications method needs to be overrided"
    end

    def load_notification(attrs)
      Notification.unread.find_or_initialize_by(attrs)
    end

    def perform(activity_id)
      @activity = PublicActivity::Activity.find_by(id: activity_id)
      return if @activity.nil? || @activity.notified?
      notifications.each do |notification|
        notification.add_sender(@activity.owner)
        notification.send!
      end
      @activity.update notified: true
      notifications
    end
  end
end
