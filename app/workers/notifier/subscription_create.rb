module Notifier
  # performs the notification for activities with subscription.create key
  # creates notifications for the stack owner
  # ex. 4 people have started following your stack
  class SubscriptionCreate < Base
    def owner_notification
      stack = @activity.recipient
      return if stack.nil? || @activity.owner_id == stack.user_id
      load_notification subject: stack,
                        user_id: stack.user_id,
                        action: @activity.key,
                        extra: {
                          stack_id: stack.id
                        }
    end

    def notifications
      [owner_notification].compact
    end
  end
end
