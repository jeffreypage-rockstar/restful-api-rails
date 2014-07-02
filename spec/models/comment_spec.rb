require 'rails_helper'

RSpec.describe Comment, :type => :model do
  let(:card) { create(:card) }
  let(:user) { card.user }
  
  describe ".create" do
    let(:attrs) do
      {
        body: "Check this comment @#{user.username}",
        card: card,
        user: user
      }
    end

    it "creates a valid comment" do
      expect(Comment.new(attrs)).to be_valid
    end

    it "requires a card" do
      comment = Comment.new(attrs.merge(card: nil))
      expect(comment).to_not be_valid
    end
    
    it "requires a user" do
      comment = Comment.new(attrs.merge(card: nil))
      expect(comment).to_not be_valid
    end
    
    it "extracts the correct mentions" do
      comment = Comment.create(attrs)
      expect(comment.mentions[user.username]).to eql user.id
    end
  end
end
