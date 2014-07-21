require 'rails_helper'

RSpec.describe Reputation, :type => :model do
  
  describe ".create" do
    let(:attrs) { {name: "Accepted", min_score: 0} }

    it "creates a valid reputation" do
      expect(Reputation.new(attrs)).to be_valid
    end

    it "requires a name" do
      reputation = Reputation.new(attrs.merge(name: ""))
      expect(reputation).to_not be_valid
    end

    it "requires a min_score" do
      reputation = Reputation.new(attrs.merge(min_score: nil))
      expect(reputation).to_not be_valid
    end

    it "requires a unique min_score and name" do
      Reputation.create(attrs)
      reputation = Reputation.new(attrs)
      expect(reputation).to_not be_valid
      expect(reputation.errors[:name].first).to match "taken"
      expect(reputation.errors[:min_score].first).to match "taken"
    end
  end
end
