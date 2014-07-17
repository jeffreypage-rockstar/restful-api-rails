module Notifier
  # performs the notification for activities with card.create key
  # creates notifications for the stack owner and for stack subscribers
  class CardCreate < Base
    def owner_notification
      card = @activity.trackable
      if @activity.owner_id != card.stack.try(:user_id)
        load_notification subject: card,
                          user_id: card.stack.try(:user_id),
                          action: @activity.key
      end
    end

    def subscribers_notifications
      card = @activity.trackable
      Subscriber.where(stack_id: card.stack_id).map do |s|
        load_notification subject: card,
                          user_id: s.user_id,
                          action: @activity.key
      end
    end

    def notifications
      all_notifications = subscribers_notifications
      all_notifications << owner_notification
      all_notifications.uniq { |n| n.user_id  }
    end
  end
end