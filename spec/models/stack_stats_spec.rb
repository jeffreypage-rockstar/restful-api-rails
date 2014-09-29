require "rails_helper"

RSpec.describe StackStats, type: :model do
  let(:stack) { create(:stack) }

  describe ".generate" do
    before do
      PublicActivity.with_tracking do
        @subscriptions = (1..3).map { create(:subscription, stack: stack) }
        @unsubscription = @subscriptions.pop
        @unsubscription.destroy
      end
    end

    it "generates stats rows for a date interval" do
      StackStats.generate(1.day.ago, Time.current)
      stats = StackStats.find_by(date: Date.today, stack: stack)
      expect(stats.subscriptions).to eql 3
      expect(stats.unsubscriptions).to eql 1
    end
  end

  describe ".create" do
    let(:attrs) do
      { stack: stack, date: Date.today }
    end

    it "creates a valid stack_stats" do
      stats = StackStats.new(attrs)
      expect(stats).to be_valid
    end

    it "requires a date" do
      stats = StackStats.new(attrs.merge(date: nil))
      expect(stats).to_not be_valid
    end

    it "requires a stack" do
      stats = StackStats.new(attrs.merge(stack: nil))
      expect(stats).to_not be_valid
    end

    it "request a unique date for a stack" do
      stats = StackStats.create(attrs)
      expect(stats).to be_valid
      other_stats = StackStats.new(attrs)
      expect(other_stats).to_not be_valid
      expect(other_stats.errors[:date].first).to match "taken"
    end
  end
end
