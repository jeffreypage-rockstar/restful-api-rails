require "rails_helper"

RSpec.describe Stack, type: :model do
  let(:user) { create(:user) }

  describe ".create" do

    let(:attrs) do
      {
        name: "My Stack Title",
        description: "My stack description",
        user_id: user.id
      }
    end

    it "creates a valid stack" do
      expect(Stack.new(attrs)).to be_valid
    end

    it "requires a name" do
      stack = Stack.new(attrs.merge(name: ""))
      expect(stack).to_not be_valid
    end

    it "requires a user" do
      stack = Stack.new(attrs.merge(user_id: ""))
      expect(stack).to_not be_valid
    end

    it "requires a unique name" do
      stack = create(:stack)
      other = Stack.new(attrs.merge(name: stack.name))
      expect(other).to_not be_valid
      expect(other.errors[:name].first).to match("taken")
    end

    it "sets a default protected as false" do
      stack = Stack.new(attrs)
      expect(stack.protected?).to eql false
    end

    it "accepts protected as true" do
      stack = Stack.new(attrs.merge(protected: true))
      expect(stack).to be_valid
      expect(stack.protected?).to eql true
    end

    it "generates an activity entry for create" do
      PublicActivity.with_tracking do
        stack = Stack.create(attrs)
        act = stack.activities.last
        expect(act.key).to eql "stack.create"
        expect(act.owner_id).to eql user.id
      end
    end
  end

  describe "#subscriptions_count" do
    it "auto updates subscriptions_count" do
      stack = create(:stack)
      expect(stack.subscriptions_count).to eql 0
      create(:subscription, stack: stack)
      expect(stack.reload.subscriptions_count).to eql 1
    end
  end
end
