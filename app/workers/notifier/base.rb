module Notifier
  class Base
    include Sidekiq::Worker

    def notifications
      raise "notifications method needs to be overwritten"
    end

    def load_notification(attrs)
      extra = attrs.delete(:extra)
      Notification.unread.find_or_initialize_by(attrs).tap do |notification|
        notification.extra = extra
      end
    end

    def perform(activity_id)
      @activity = PublicActivity::Activity.find_by(id: activity_id)
      return if @activity.nil? || @activity.notified?
      result = notifications.map do |notification|
        notification.add_sender(@activity.owner)
        notification.save!
        notification.send!
        notification
      end
      @activity.update notified: true
      result
    end
  end
end
