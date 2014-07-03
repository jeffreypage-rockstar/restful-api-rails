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
      card = Card.new(attrs.merge(name: ""))
      expect(card).to_not be_valid
    end

    it "requires a user_id" do
      card = Card.new(attrs.merge(user: nil))
      expect(card).to_not be_valid
    end

    it "requires a stack_id" do
      card = Card.new(attrs.merge(stack: nil))
      expect(card).to_not be_valid
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
      expect(card.vote_by!(user)).to be_valid
      expect(card.votes.size).to eql 1
      expect(card.votes.up_votes.size).to eql 1
      expect(card.reload.score).to eql 1
    end

    it "accepts a downvote, updating score" do
      expect(card.vote_by!(user, kind: "down")).to be_valid
      expect(card.votes.size).to eql 1
      expect(card.votes.up_votes.size).to eql 0
      expect(card.votes.down_votes.size).to eql 1
      expect(card.reload.score).to eql -1
    end

    it "changes the vote if already exists" do
      card.vote_by!(user)
      expect(card.reload.score).to eql 1
      expect(card.votes.size).to eql 1

      expect(card.vote_by!(user, kind: :down)).to be_valid
      expect(card.reload.score).to eql -1
      expect(card.votes.size).to eql 1
    end
  end

  describe "#flag_by!" do
    it "stores a flag to the card, updating flags_count" do
      expect(card.flag_by!(user)).to be_valid
      expect(card.reload.flags.size).to eql 1
      expect(card.flags_count).to eql 1
    end

    it "does not acceps duplicated flag" do
      flag = card.flag_by!(user)
      other_flag = card.flag_by!(user)
      expect(flag.id).to eql other_flag.id
      expect(card.reload.flags_count).to eql 1
    end
  end
end
