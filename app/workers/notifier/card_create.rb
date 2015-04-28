module Notifier
  # performs the notification for activities with card.create key
  # creates notifications for the stack owner and for stack subscribers
  # ex. 7 people have posted in a window you created
  # ex. 7 people have posted in a window you follow
  class CardCreate < Base
    BATCH_SIZE = 1000

    def extra_for(card)
      {
        stack_id: card.stack_id,
        card_id: card.id
      }
    end

    def notification_atts
      {
        subject: stack,
        action: @activity.key,
        extra: extra_for(card)
      }
    end

    def card
      @activity.trackable
    end

    def stack
      @activity.recipient
    end

    def each_user_group(&block)
      # notify subscriptions
      Subscription.where(stack_id: stack.id).
                   where.not(user_id: @activity.owner_id).
                   find_in_batches(batch_size: BATCH_SIZE) do |subs|
        block.call(subs.map(&:user_id))
      end
    end

    def load_notifications_for(user_ids)
      # 1. find existent notifications to update
      notifications = Notification.unread.where(subject: stack,
                                                action: @activity.key,
                                                user_id: user_ids)
      # 2. create not reusable notifications
      missing = (user_ids - notifications.pluck(:user_id)).map do |uid|
        Notification.new(notification_atts.merge(user_id: uid))
      end
      if missing.any?
        columns = Notification.column_names - ["id"]
        Notification.import columns, missing, validate: false
      end
      # 3. return all notifications ids
      notifications.pluck(:id)
    end

    def error_messages
      errors = []
      errors << "cannot find card" if card.nil?
      errors << "cannot find stack" if stack.nil?
      errors
    end

    def perform(activity_id)
      @activity = PublicActivity::Activity.find_by(id: activity_id)
      return if @activity.nil? || @activity.notified?
      if error_messages.empty?
        publisher = NotificationPublishService.new
        base_notification = Notification.new(notification_atts)
        base_notification.senders.build(user_id: @activity.owner.id,
                                        username: @activity.owner.username)

        each_user_group do |user_ids|
          notification_ids = load_notifications_for(user_ids)
          # insert senders
          NotificationSender.mass_insert_user(@activity.owner,
                                              notification_ids)
          # mark all notifications as sent
          Notification.mark_all_as_sent(notification_ids)
          # update user counters
          User.increment_counter(:unseen_notifications_count, user_ids)
          # send a push notification to all users
          # publisher.publish_to_users(base_notification, user_ids)
          # -> temporary disabling push notifications
        end
      end
      @activity.update_columns notified: true,
                               notification_error: error_messages.join(", ")
    end
  end
end
