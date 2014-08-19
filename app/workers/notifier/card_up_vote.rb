module Notifier
  # performs the notification for activities with card.up_vote key
  # creates notifications for the card owner
  # Ex. 217 people have liked your post
  class CardUpVote < Base
    def owner_notification
      card = @activity.trackable
      return nil if card.nil? || @activity.owner_id == card.user_id
      load_notification subject: card,
                        user_id: card.user_id,
                        action: @activity.key
    end

    def notifications
      [owner_notification].compact
    end
  end
end
