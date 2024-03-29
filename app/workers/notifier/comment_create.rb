module Notifier
  # performs the notification for activities with comment.create key
  # creates notifications for the card owner, comment mentions and replies
  # ex. 23 people have commented on your post
  # ex. User mentioned you in a comment
  # ex. Plotchman1 replied to your comment
  class CommentCreate < Base
    def owner_notification
      comment = @activity.trackable
      card = @activity.recipient
      return if card.nil? || @activity.owner_id == card.user_id
      load_notification subject: card,
                        user_id: card.user_id,
                        action: @activity.key,
                        extra: extra_for(comment, card)
    end

    def reply_notification
      comment = @activity.trackable
      card = @activity.recipient
      valid = comment.replying && comment.user_id != comment.replying.user_id
      return unless valid
      load_notification subject: card,
                        user_id: comment.replying.user_id,
                        action: "comment.reply",
                        extra: extra_for(comment, card)
    end

    def mentions_notifications
      comment = @activity.trackable
      card = @activity.recipient
      comment.mentions.map do |_username, user_id|
        load_notification subject: card,
                          user_id: user_id,
                          action: "comment.mention",
                          extra: extra_for(comment, card)
      end
    end

    def extra_for(comment, card)
      {
        comment_id: comment.id,
        card_id: card.id,
        stack_id: card.stack_id
      }
    end

    def notifications
      all_notifications = []
      all_notifications << reply_notification
      all_notifications += mentions_notifications
      all_notifications << owner_notification
      all_notifications.compact.uniq { |n| n.user_id  }
    end
  end
end
