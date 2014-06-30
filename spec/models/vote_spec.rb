require "rails_helper"

RSpec.describe Vote, type: :model do
  describe ".create" do
    let(:vote) { create(:vote) }
    let(:card) { create(:card) }

    let(:attrs) do
      {
        votable: card,
        user: card.user
      }
    end

    it "creates a valid vote" do
      expect(Vote.new(attrs)).to be_valid
    end

    it "requires a votable" do
      vote = Vote.new(attrs.merge(votable: nil))
      expect(vote).to_not be_valid
    end

    it "requires a user" do
      vote = Vote.new(attrs.merge(user: nil))
      expect(vote).to_not be_valid
    end

    it "requires a unique vote by user+votable combination" do
      other = Vote.new(attrs.merge(votable: vote.votable, user: vote.user))
      expect(other).to_not be_valid
      expect(other.errors[:user_id].first).to match "taken"
    end
  end
end
