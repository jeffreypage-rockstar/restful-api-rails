require "rails_helper"

RSpec.describe Stats, type: :model do

  describe ".generate" do
    before do
      (1..2).each { create(:deleted_user) }
      @comment = create(:comment)
    end

    it "generates stats rows for a date interval" do
      Stats.generate(1.day.ago, Time.current)
      stats = Stats.find(Date.today)
      expect(stats.users).to eql 3
      expect(stats.deleted_users).to eql 2
      expect(stats.stacks).to eql 1
      expect(stats.cards).to eql 1
      expect(stats.comments).to eql 1
    end

    it "generates stats with flagged counters" do
      @comment.flag_by!(@comment.user)
      Stats.generate(1.day.ago, Time.current)
      stats = Stats.find(Date.today)
      expect(stats.users).to eql 3
      expect(stats.flagged_comments).to eql 1
      expect(stats.flagged_cards).to eql 0
      expect(stats.flagged_users).to eql 0
    end
  end

  describe ".create" do
    it "requires a date" do
      stats = Stats.new
      expect(stats).to_not be_valid
    end

    it "request a unique date" do
      stats = Stats.create(date: Time.current)
      expect(stats).to be_valid
      other_stats = Stats.new(date: Date.today)
      expect(other_stats).to_not be_valid
    end
  end
end
