# A sidekiq worker to update stack_stats table
class StackStatsUpdaterWorker
  include Sidekiq::Worker

  def perform
    if StackStats.exists?
      start_date = StackStats.latest.first.date
      if start_date.today?
        StackStats.generate(start_date, start_date)
      else
        StackStats.generate(start_date + 1.day, Time.current)
      end
    elsif Subscription.exists?
      start_date = Subscription.order(created_at: :asc).first.try(:created_at)
      StackStats.generate(start_date, Time.current)
    end
  end
end
