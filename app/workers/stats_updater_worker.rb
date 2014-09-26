# A sidekiq worker to update stats table
class StatsUpdaterWorker
  include Sidekiq::Worker

  def perform
    if Stats.exists?
      start_date = Stats.latest.first.date
      if start_date.today?
        Stats.generate(start_date, start_date)
      else
        Stats.generate(start_date + 1.day, Time.current)
      end
    elsif User.exists?
      start_date = User.order(created_at: :asc).first.try(:created_at)
      Stats.generate(start_date, Time.current)
    end
  end
end
