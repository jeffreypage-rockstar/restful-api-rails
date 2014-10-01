require "rails_helper"

RSpec.describe StackStatsUpdaterWorker, type: :worker do
  let(:worker) { StackStatsUpdaterWorker.new }

  describe "when no stats exists" do
    it "generates using latest subscription created date" do
      date = 10.days.ago
      current = Time.current
      allow(Time).to receive(:current).and_return(current)
      create(:subscription, created_at: date)
      expect(StackStats).to receive(:generate).with(date, current)
      worker.perform
    end
  end

  describe "when a stats exists" do
    it "generates using latest stats date, including today" do
      date = 10.days.ago.to_date
      next_date = date + 1.day
      create(:stack_stats, date: date)
      current = Time.current
      allow(Time).to receive(:current).and_return(current)
      expect(StackStats).to receive(:generate).with(next_date, current)
      worker.perform
    end

    it "always generate if last date is today" do
      date = Date.today
      create(:stack_stats, date: date)
      expect(StackStats).to receive(:generate).with(date, date)
      worker.perform
    end
  end

  describe "when no stats or subscription exists" do
    it "returns without generating" do
      expect(StackStats).to_not receive(:generate)
      expect(worker.perform).to be_falsey
    end
  end

end
