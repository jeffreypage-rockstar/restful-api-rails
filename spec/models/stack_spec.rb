require "rails_helper"

RSpec.describe Stack, type: :model do

  describe ".create" do

    let(:attrs) do
      {
        name: "My Stack Title",
        user_id: 1
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
  end
end
