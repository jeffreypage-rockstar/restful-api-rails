module Notifier
  # performs the notification for activities with card.create key
  # creates notifications for the stack owner and for stack subscribers
  # ex. 7 people have posted in a window you created
  # ex. 7 people have posted in a window you follow
  class CardCreate < Base
    def owner_notification
      card = @activity.trackable
      return nil if card.nil? || @activity.owner_id == card.stack.try(:user_id)
      load_notification subject: card,
                        user_id: card.stack.try(:user_id),
                        action: @activity.key,
                        extra: extra_for(card)
    end

    def subscribers_notifications
      card = @activity.trackable
      return [] unless card
      Subscription.where(stack_id: card.stack_id).
                   where.not(user_id: @activity.owner_id).
                   map do |s|
        load_notification subject: card,
                          user_id: s.user_id,
                          action: @activity.key,
                          extra: extra_for(card)
      end
    end

    def extra_for(card)
      {
        stack_id: card.stack_id,
        card_id: card.id
      }
    end

    def notifications
      all_notifications = subscribers_notifications
      all_notifications << owner_notification
      all_notifications.compact.uniq { |n| n.user_id  }
    end
  end
end
