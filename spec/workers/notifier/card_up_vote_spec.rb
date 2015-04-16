require "rails_helper"

RSpec.describe Notifier::CardUpVote, type: :worker do
  let(:worker) { Notifier::CardUpVote.new }

  before do
    expect(Notifier::CardUpVote).to receive(:perform_async).once.
                                    and_return("0001")
  end

  it "performs generating notifications for card owner" do
    card = create(:card)
    other_user = create(:user)

    PublicActivity.with_tracking do
      card.vote_by!(other_user)
      act = card.activities.where(key: "card.up_vote").last
      worker.perform(act.id)
      notifications = Notification.where(action: "card.up_vote").all
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 1
      notifications.each { |n| expect(n).to be_persisted }
      notifications.each { |n| expect(n).to be_sent }
      expect(card.user.notifications.unread.count).to eql 1
    end
  end

  it "does not notify if card owner has been removed" do
    card = create(:card)
    other_user = create(:user)

    PublicActivity.with_tracking do
      card.vote_by!(other_user)
      card.user.destroy
      act = card.activities.where(key: "card.up_vote").last
      worker.perform(act.id)
      notifications = Notification.where(action: "card.up_vote").all
      expect(act.reload).to be_notified
      expect(act.notification_error).to match "User can't be blank"
      expect(notifications.size).to eql 0
    end
  end

  it "updates existent unread notification for the same user" do
    card = create(:card)
    user1 = create(:user)
    # adding notification for user1 up_vote card
    up_notification = create(:notification, user: card.user,
                                            subject: card,
                                            action: "card.up_vote")
    up_notification.add_sender(user1)
    user2 = create(:user)
    PublicActivity.with_tracking do
      card.vote_by!(user2)
      act = card.activities.where(key: "card.up_vote").last
      worker.perform(act.id)
      notifications = Notification.where(action: "card.up_vote").all
      expect(notifications.size).to eql 1
      expect(notifications.first.id).to eql up_notification.id
      expect(notifications.first.senders_count).to eql 2
      usernames = notifications.first.senders.map(&:username).sort
      expect(usernames).to include(user1.username)
      expect(usernames).to include(user2.username)
      expect(notifications.first.extra.keys).to match(["stack_id", "card_id"])
    end
  end
end
