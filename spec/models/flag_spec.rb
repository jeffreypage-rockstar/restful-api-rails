require "rails_helper"

RSpec.describe Flag, type: :model do
  let(:flag) { create(:flag) }
  let(:card) { create(:card) }

  describe ".create" do
    let(:attrs) do
      {
        flaggable: card,
        user: card.user
      }
    end

    it "creates a valid flag" do
      expect(Flag.new(attrs)).to be_valid
    end

    it "requires a flaggable" do
      flag = Flag.new(attrs.merge(flaggable: nil))
      expect(flag).to_not be_valid
    end

    it "requires a user" do
      flag = Flag.new(attrs.merge(user: nil))
      expect(flag).to_not be_valid
    end

    it "requires a unique flag by user+flaggable combination" do
      other = Flag.new(attrs.merge(flaggable: flag.flaggable, user: flag.user))
      expect(other).to_not be_valid
      expect(other.errors[:user_id].first).to match "taken"
    end
  end
end
