require "rails_helper"

RSpec.describe StatsUpdaterWorker, type: :worker do
  let(:worker) { StatsUpdaterWorker.new }

  describe "when no stats exists" do
    it "generates using latest user created date" do
      date = 10.days.ago
      current = Time.current
      allow(Time).to receive(:current).and_return(current)
      create(:user, created_at: date)
      expect(Stats).to receive(:generate).with(date, current)
      worker.perform
    end
  end

  describe "when a stats exists" do
    it "generates using latest stats date, including today" do
      date = 10.days.ago.to_date
      next_date = date + 1.day
      Stats.create(date: date)
      current = Time.current
      allow(Time).to receive(:current).and_return(current)
      expect(Stats).to receive(:generate).with(next_date, current)
      worker.perform
    end

    it "always generate if last date is today" do
      date = Date.today
      Stats.create(date: date)
      expect(Stats).to receive(:generate).with(date, date)
      worker.perform
    end
  end

  describe "when no stats or user exists" do
    it "returns without generating" do
      expect(Stats).to_not receive(:generate)
      expect(worker.perform).to be_falsey
    end
  end

end
