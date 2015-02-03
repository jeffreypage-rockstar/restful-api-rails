module Notifier
  # performs the notification for activities with card.create key
  # creates notifications for the stack owner and for stack subscribers
  # ex. 7 people have posted in a window you created
  # ex. 7 people have posted in a window you follow
  class CardCreate < Base
    SUBSCRIPTION_BATCH_SIZE = 100

    def owner_notification
      card = @activity.trackable
      stack = @activity.recipient
      return if card.nil? || stack.nil? || @activity.owner_id == stack.user_id
      load_notification subject: stack,
                        user_id: stack.user_id,
                        action: @activity.key,
                        extra: extra_for(card)
    end

    def each_subscription_notification(&block)
      return unless block_given?
      card = @activity.trackable
      stack = @activity.recipient
      return [] if card.nil? || stack.nil?
      Subscription.where(stack_id: stack.id).
                   where.not(user_id: @activity.owner_id).
                   find_each(batch_size: SUBSCRIPTION_BATCH_SIZE) do |s|
        block.call load_notification(subject: stack,
                                     user_id: s.user_id,
                                     action: @activity.key,
                                     extra: extra_for(card))
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

    # overwriting each_notification to load subscription in batches
    def each_notification(&block)
      return unless block_given?
      yield(owner_notification) if owner_notification
      each_subscription_notification(&block)
    end
  end
end
