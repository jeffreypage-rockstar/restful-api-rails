require "rails_helper"

RSpec.describe NotificationSender, type: :model do
  let(:user) { create(:user) }
  let(:notification) { create(:notification) }

  describe ".create" do
    let(:attrs) do
      {
        notification_id: notification.id,
        user_id: user.id,
        username: user.username
      }
    end

    it "creates a valid notification sender" do
      expect(NotificationSender.new(attrs)).to be_valid
    end

    it "requires a user" do
      notification = NotificationSender.new(attrs.merge(user_id: nil))
      expect(notification).to_not be_valid
    end

    it "requires a notification" do
      notification = NotificationSender.new(attrs.merge(notification_id: nil))
      expect(notification).to_not be_valid
    end

    it "requires a username" do
      notification = NotificationSender.new(attrs.merge(username: ""))
      expect(notification).to_not be_valid
    end
  end

  describe "#mass_insert_user" do
    it "adds a sender to several notifications, avoiding conflicts" do
      notifications = create_list(:notification, 3)
      notifications.first.add_sender(user)
      NotificationSender.mass_insert_user(user, notifications.map(&:id))
      notifications.each do |notification|
        notification.reload
        expect(notification.senders_count).to eql 1
        expect(notification.senders.count).to eql 1
        expect(notification.senders.first.user_id).to eql user.id
      end
    end
  end
end
