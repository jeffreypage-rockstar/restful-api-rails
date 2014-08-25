require "rails_helper"

RSpec.describe Subscription, type: :model do

  describe ".create" do
    let(:attrs) do
      {
        stack_id: "2f165abe-6168-4989-b3ca-b038ca0ba327",
        user_id: "2f165abe-6168-4989-b3ca-b038ca0ba328"
      }
    end

    it "creates a valid subscription" do
      expect(Subscription.new(attrs)).to be_valid
    end

    it "requires a user" do
      subs = Subscription.new(attrs.merge(user_id: ""))
      expect(subs).to_not be_valid
    end

    it "requires a stack" do
      subs = Subscription.new(attrs.merge(stack_id: ""))
      expect(subs).to_not be_valid
    end

    it "requires a unique stack for the user" do
      subs = create(:subscription)
      other = Subscription.new(attrs.merge(stack_id: subs.stack_id,
                                           user_id: subs.user_id))
      expect(other).to_not be_valid
      expect(other.errors[:stack_id].first).to match("taken")
    end

    it "removes old subscriptions if user reaches the maximum" do
      user = create(:user)
      first_sub = create(:subscription, user: user)
      stub_const("Subscription::MAX_USER_SUBSCRIPTIONS", 5)
      max = Subscription::MAX_USER_SUBSCRIPTIONS
      (2..max).each { create(:subscription, user: user) }
      expect(user.reload.subscriptions.count).to eql max
      create(:subscription, user: user)
      expect(user.reload.subscriptions.count).to eql max
      expect { first_sub.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
