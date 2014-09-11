require "rails_helper"

RSpec.describe Notifier::SubscriptionCreate, type: :worker do
  let(:worker) { Notifier::SubscriptionCreate.new }
  let(:stack) { create :stack }

  before do
    expect(Notifier::SubscriptionCreate).to receive(:perform_async).once.
                                    and_return("0001")
  end

  it "generates notification subscription on stack" do
    PublicActivity.with_tracking do
      subscription = create(:subscription, stack: stack)
      act = subscription.activities.where(key: "subscription.create").last
      notifications = worker.perform(act.id)
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 1
      expect(notifications.first).to be_persisted
      expect(notifications.first).to be_sent
      expect(stack.user.notifications.unread.count).to eql 1
    end
  end
end
