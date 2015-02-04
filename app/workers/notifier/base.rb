module Notifier
  class Base
    include Sidekiq::Worker

    def notifications
      raise "notifications method needs to be overwritten"
    end

    def each_notification(&block)
      notifications.each(&block) if block_given?
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
      publisher = NotificationPublishService.new
      error_message = ""
      each_notification do |notification|
        begin
          notification.add_sender(@activity.owner)
          notification.sent!
          publisher.publish(notification)
        rescue ActiveRecord::RecordInvalid => e
          error_message = e.message
        end
      end
      @activity.update_columns notified: true,
                               notification_error: error_message
    end
  end
end
