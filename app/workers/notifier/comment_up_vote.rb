module Notifier
  # performs the notification for activities with comment.up_vote key
  # creates notifications for the comment owner
  # Ex. 217 people have liked your comment
  class CommentUpVote < Base
    def owner_notification
      comment = @activity.trackable
      return nil if comment.nil? || @activity.owner_id == comment.user_id
      load_notification subject: comment,
                        user_id: comment.user_id,
                        action: @activity.key,
                        extra: {
                          comment_id: comment.id,
                          card_id: comment.card_id,
                          stack_id: comment.card.try(:stack_id)
                        }
    end

    def notifications
      [owner_notification].compact
    end
  end
end
