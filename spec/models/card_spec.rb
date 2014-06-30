require "rails_helper"

RSpec.describe Card, type: :model do
  let(:card) { create(:card) }
  let(:user) { create(:user) }

  describe ".create" do
    let(:stack) { create(:stack) }

    let(:attrs) do
      {
        name: "My Card Title",
        description: "My card description",
        stack: stack,
        user: stack.user
      }
    end

    it "creates a valid card" do
      expect(Card.new(attrs)).to be_valid
    end

    it "requires a name" do
      stack = Card.new(attrs.merge(name: ""))
      expect(stack).to_not be_valid
    end

    it "requires a user_id" do
      stack = Card.new(attrs.merge(user: nil))
      expect(stack).to_not be_valid
    end

    it "requires a stack_id" do
      stack = Card.new(attrs.merge(stack: nil))
      expect(stack).to_not be_valid
    end

    it "generates a short_id on save" do
      card = create(:card)
      expect(card.short_id).to_not be_blank
    end
  end

  describe "#images" do
    it "accepts images setting positions" do
      card.images << build(:card_image)
      card.images << build(:card_image)
      expect(card.save).to eql true
      card.reload
      expect(card.images.size).to eql 2
      expect(card.images.map(&:position)).to eql [1, 2]
    end
  end

  describe "#vote_by!" do
    it "accepts an upvote, updating score" do
      expect(card.vote_by!(user)).to eql true
      expect(card.votes.size).to eql 1
      expect(card.votes.up_votes.size).to eql 1
      expect(card.reload.score).to eql 1
    end

    it "accepts a downvote, updating score" do
      expect(card.vote_by!(user, up_vote: false)).to eql true
      expect(card.votes.size).to eql 1
      expect(card.votes.up_votes.size).to eql 0
      expect(card.votes.down_votes.size).to eql 1
      expect(card.reload.score).to eql -1
    end

    it "changes the vote if already exists" do
      card.vote_by!(user)
      expect(card.reload.score).to eql 1
      expect(card.votes.size).to eql 1

      expect(card.vote_by!(user, up_vote: false)).to eql true
      expect(card.reload.score).to eql -1
      expect(card.votes.size).to eql 1
    end
  end
end
