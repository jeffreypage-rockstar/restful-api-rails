require "rails_helper"

RSpec.describe Stack, type: :model do
  let(:user) { create(:user) }

  describe ".create" do

    let(:attrs) do
      {
        name: "#MyStackTitle",
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
      stack = Stack.new(attrs.merge(user: nil))
      expect(stack).to_not be_valid
    end

    it "requires a unique name, case insensitive" do
      stack = create(:stack)
      other = Stack.new(attrs.merge(name: stack.name.upcase))
      expect(other).to_not be_valid
      expect(other.errors[:name].first).to match("taken")
    end

    it "requires a numeric subscriptions_count" do
      stack = Stack.new(attrs.merge(subscriptions_count: "aaa"))
      expect(stack).to_not be_valid
      expect(stack.errors[:subscriptions_count].first).to match("number")
    end

    it "does allow special chars to stack names" do
      stack = Stack.new(attrs.merge(name: "Stack name with spaces"))
      expect(stack).to_not be_valid
      expect(stack.errors[:name].first).to match("invalid")
    end

    it "always store the name without the initial hash (#)" do
      stack = Stack.create(attrs)
      expect(stack.name).to eql "MyStackTitle"
      expect(stack.display_name).to eql "#MyStackTitle"
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

    it "stores a new value when updating" do
      stack = create(:stack)
      expect(stack.subscriptions_count).to eql 0
      stack.update subscriptions_count: 10
      expect(stack.reload.subscriptions_count).to eql 10
    end
  end

  describe ".trending" do
    it "returns trending stacks for a user" do
      create(:stack)
      create(:stack, user: user)
      create(:subscription, user: user)
      expect(Stack.trending(user.id).count).to eql 1
    end
  end
end
