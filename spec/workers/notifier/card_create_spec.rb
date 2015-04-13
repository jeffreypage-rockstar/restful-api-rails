require "rails_helper"

RSpec.describe Notifier::CardCreate, type: :worker do
  let(:worker) { Notifier::CardCreate.new }
  let(:card) { create(:card) }
  let(:stack) { card.stack }

  before do
    allow(Notifier::SubscriptionCreate).to receive(:perform_async)
  end

  it "performs generating notifications for stack subscribers" do
    expect(Notifier::CardCreate).to receive(:perform_async).twice.
                                    and_return("0001")
    PublicActivity.with_tracking do
      subs = create_list(:subscription, 2, stack: stack)
      new_card = create(:card, stack: stack)
      act = new_card.activities.where(key: "card.create").last
      worker.perform(act.id)
      notifications = Notification.where(action: "card.create").all
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 2
      notifications.each { |n| expect(n).to be_persisted }
      notifications.each { |n| expect(n).to be_sent }
      subs.each do |s|
        s.reload
        expect(s.user.notifications.unread.count).to eql 1
        expect(s.user.unseen_notifications_count).to eql 1
      end
    end
  end

  it "updates an existent unread notification" do
    expect(Notifier::CardCreate).to receive(:perform_async).twice.
                                    and_return("0001")
    PublicActivity.with_tracking do
      subs = create_list(:subscription, 2, stack: stack)
      new_card = create(:card, stack: stack)
      existent_notification = create(:card_create_notification,
                                     read: false,
                                     subject: stack,
                                     user_id: subs.first.user_id)
      act = new_card.activities.where(key: "card.create").last
      worker.perform(act.id)
      notifications = Notification.where(action: "card.create").all
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 2
      expect(notifications.map(&:id)).to be_include(existent_notification.id)
      notifications.each { |n| expect(n).to be_persisted }
      notifications.each { |n| expect(n).to be_sent }
      subs.each do |s|
        s.reload
        expect(s.user.notifications.unread.count).to eql 1
        expect(s.user.unseen_notifications_count).to eql 1
      end
    end
  end

  it "does not notify activity owner as a subscriber" do
    expect(Notifier::CardCreate).to receive(:perform_async).twice.
                                    and_return("0001")
    PublicActivity.with_tracking do
      user = create(:user)
      create(:subscription, stack: stack, user: user)
      new_card = create(:card, stack: stack, user: user)
      act = new_card.activities.where(key: "card.create").last
      worker.perform(act.id)
      notifications = Notification.where(action: "card.create").all
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 0
      expect(user.notifications.unread.count).to eql 0
    end
  end

  it "does not notify for an invalid card" do
    expect(Notifier::CardCreate).to receive(:perform_async).once.
                                      and_return("00001")
    user = create(:user)
    act = create(:activity, trackable_id: user.id)
    worker.perform(act.id)
    expect(Notification.where(action: "card.create")).to be_empty
    expect(act.reload).to be_notified
  end
end
