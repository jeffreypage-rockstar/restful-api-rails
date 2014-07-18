require "rails_helper"

RSpec.describe Notifier::CommentCreate, type: :worker do
  let(:worker) { Notifier::CommentCreate.new }

  before do
    expect(Notifier::CommentCreate).to receive(:perform_async).once.
                                    and_return("0001")
  end

  it "performs generating notifications for card owner and mentions" do
    card = create(:card)
    other_user = create(:user)
    PublicActivity.with_tracking do
      comment = create(:comment, card: card,
                                 body: "a comment for @#{other_user.username}")
      act = comment.activities.where(key: "comment.create").last
      notifications = worker.perform(act.id)
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 2
      notifications.each { |n| expect(n).to be_persisted }
      notifications.each { |n| expect(n).to be_sent }
      expect(card.user.notifications.unread.count).to eql 1
      expect(other_user.notifications.unread.count).to eql 1
      mention_notification = other_user.notifications.unread.first
      expect(mention_notification.action).to eql "comment.mention"
    end
  end

  it "generates notification when replying" do
    card = create(:card)
    comment = create(:comment, card: card, user: card.user)
    PublicActivity.with_tracking do
      reply = create(:comment, replying: comment, card: card)
      act = reply.activities.where(key: "comment.create").last
      notifications = worker.perform(act.id)
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 1
      expect(notifications.first.action).to eql "comment.reply"
      expect(comment.user.notifications.unread.count).to eql 1
    end
  end
end
