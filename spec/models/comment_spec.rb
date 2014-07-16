require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:card) { create(:card) }
  let(:user) { comment.user }
  let(:comment) { create(:comment, card: card) }

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

    it "generates an activity entry for create" do
      PublicActivity.with_tracking do
        comment = Comment.create(attrs)
        act = comment.activities.last
        expect(act.key).to eql "comment.create"
        expect(act.owner_id).to eql user.id
        expect(act.recipient_id).to eql card.id
      end
    end
  end

  describe "#vote_by!" do
    it "accepts an upvote, updating score" do
      expect(comment.vote_by!(user)).to be_valid
      expect(comment.votes.size).to eql 1
      expect(comment.votes.up_votes.size).to eql 1
      expect(comment.reload.score).to eql 1
      expect(comment.user.score).to eql 1
    end

    it "accepts a downvote, updating score" do
      expect(comment.vote_by!(user, kind: "down")).to be_valid
      expect(comment.votes.size).to eql 1
      expect(comment.votes.up_votes.size).to eql 0
      expect(comment.votes.down_votes.size).to eql 1
      expect(comment.reload.score).to eql -1
      expect(comment.user.score).to eql -1
    end

    it "changes the vote if already exists" do
      comment.vote_by!(user)
      expect(comment.reload.score).to eql 1
      expect(comment.votes.size).to eql 1

      expect(comment.vote_by!(user, kind: :down)).to be_valid
      expect(comment.reload.score).to eql -1
      expect(comment.user.score).to eql -1
      expect(comment.votes.size).to eql 1
    end


    it "generates an activity entry for up_vote" do
      PublicActivity.with_tracking do
        comment.vote_by!(user)
        act = comment.activities.where(key: "comment.up_vote").last
        expect(act.owner_id).to eql user.id
      end
    end

    it "generates an activity entry for down_vote" do
      PublicActivity.with_tracking do
        comment.vote_by!(user, kind: :down)
        act = comment.activities.where(key: "comment.down_vote").last
        expect(act.owner_id).to eql user.id
      end
    end
  end

  describe "#flag_by!" do
    it "stores a flag to the comment, updating flags_count" do
      expect(comment.flag_by!(user)).to be_valid
      expect(comment.reload.flags.size).to eql 1
      expect(comment.flags_count).to eql 1
    end

    it "does not acceps duplicated flag" do
      flag = comment.flag_by!(user)
      other_flag = comment.flag_by!(user)
      expect(flag.id).to eql other_flag.id
      expect(comment.reload.flags_count).to eql 1
    end

    it "generates an activity entry for flag" do
      PublicActivity.with_tracking do
        comment.flag_by!(user)
        act = comment.activities.where(key: "comment.flag").last
        expect(act.owner_id).to eql user.id
      end
    end
  end
end
