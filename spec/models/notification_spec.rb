require "rails_helper"

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }

  describe ".create" do
    let(:attrs) { attributes_for(:notification).merge(user_id: user.id) }

    it "creates a valid notification" do
      expect(Notification.new(attrs)).to be_valid
    end

    it "requires a user" do
      notification = Notification.new(attrs.merge(user: nil))
      expect(notification).to_not be_valid
    end

    it "requires a subject" do
      notification = Notification.new(attrs.merge(subject: nil))
      expect(notification).to_not be_valid
    end

    it "requires an action" do
      notification = Notification.new(attrs.merge(action: ""))
      expect(notification).to_not be_valid
    end
  end

  describe "#mask_as_read!" do

    it "updates the notification as read" do
      notification = create(:notification)
      expect(notification).to_not be_read
      expect(notification.mask_as_read!).to eql true
      expect(notification).to be_read
    end
  end

  describe ".mark_all_as_read" do
    it "marks all user notifications as read" do
      notifications = (1..5).map { create(:notification, user: user) }
      expect(user.notifications.unread.count).to eql 5
      Notification.mark_all_as_read(user.id, notifications.last)
      expect(user.notifications.unread.count).to eql 0
    end
  end

  describe ".mark_all_as_seen" do
    it "marks all user notifications as seen" do
      notifications = (1..5).map { create(:notification, user: user) }
      expect(user.notifications.unseen.count).to eql 5
      Notification.mark_all_as_seen(user.id, notifications.last)
      expect(user.notifications.unseen.count).to eql 0
    end
  end

  describe "#add_sender" do
    it "adds a user as a notification sender" do
      notification = create(:notification)
      notification.add_sender(user)
      notification.add_sender(user)
      notification.save
      notification.reload
      expect(notification.senders_count).to eql 1
      expect(notification.senders[user.username]).to eql user.id
    end
  end

  describe "#similar_notifications" do
    it "query db for similar notifications" do
      old_notification = create(:notification)
      create(:notification) # another subject
      notification = create(:notification, subject: old_notification.subject)
      similar = notification.similar_notifications
      expect(similar.size).to eql 1
      expect(similar.first.id).to eql old_notification.id
    end
  end

  describe "#require_push_notification?" do
    it "returns true for create and reply actions" do
      notification = build(:notification, action: "card.create")
      expect(notification.require_push_notification?).to be_truthy

      notification = build(:notification, action: "comment.create")
      expect(notification.require_push_notification?).to be_truthy

      notification = build(:notification, action: "comment.reply")
      expect(notification.require_push_notification?).to be_truthy
    end

    it "returns true for first up_vote" do
      notification = build(:notification, action: "card.up_vote")
      expect(notification.require_push_notification?).to be_truthy
    end

    it "returns true for up_votes in the interval" do
      notification = create(:notification, action: "card.up_vote")
      # allow(notification.subject).to receive(:votes)
      allow(notification.subject.votes).to receive(:count).and_return(
                                              Notification::PUSH_VOTES_INTERVAL
                                            )
      expect(notification.require_push_notification?).to be_truthy
    end

    it "return false for a second up_votes" do
      notification = create(:notification, action: "card.up_vote")
      create(:notification, action: "card.up_vote",
                            subject: notification.subject)
      allow(notification.subject.votes).to receive(:count).and_return(2)
      expect(notification.require_push_notification?).to be_falsey
    end
  end

  describe "#send!" do
    it "marks the notification as sent" do
      notification = build(:notification)
      notification.send!
      expect(notification).to be_sent
    end
  end

  describe "#caption" do
    it "returns notification caption for a single sender" do
      notification = build(:notification)
      expect(notification.caption).to eql "a person has liked your post"
    end

    it "returns notification caption for a few senders" do
      senders = { "john" => 1, "peter" => 2, "michael" => 3 }
      notification = create(:notification, senders: senders)
      expected_caption = "john, peter and michael have liked your post"
      expect(notification.caption).to eql expected_caption
    end

    it "returns notification caption with many senders" do
      senders = { "john" => 1, "peter" => 2, "michael" => 3, "wendy" => 4 }
      notification = create(:notification, senders: senders)
      expect(notification.caption).to eql "4 people have liked your post"
    end
  end
end
