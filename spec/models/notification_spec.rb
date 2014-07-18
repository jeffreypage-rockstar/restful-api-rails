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
      (1..5).map { create(:notification, user: user) }
      expect(user.notifications.unread.count).to eql 5
      Notification.mark_all_as_read(user.id)
      expect(user.notifications.unread.count).to eql 0
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

  describe "#send!" do
    it "marks the notification as sent" do
      notification = build(:notification)
      notification.send!
      expect(notification).to be_sent
    end
  end
end
