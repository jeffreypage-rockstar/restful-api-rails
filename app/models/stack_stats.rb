class StackStats < ActiveRecord::Base
  self.table_name = :stack_stats

  belongs_to :stack

  validates :date, presence: true, uniqueness: { scope: :stack_id }
  validates :stack, presence: true

  scope :latest, -> { order(date: :desc) }

  def self.daily
    group_by_period("MM/DD/YYYY")
  end

  def self.weekly
    group_by_period("MM/YYYY (W)")
  end

  def self.monthly
    group_by_period("MM/YYYY")
  end

  def self.group_by_period(format)
    select_sql = <<-SQL
      to_char(date, '#{format}') as period,
      stack_id,
      sum(subscriptions) as subscriptions,
      sum(unsubscriptions) as unsubscriptions
    SQL
    select(select_sql).group(:period, :stack_id)
  end

  # GENERATING STACK STATS
  def self.generate(start_date, end_date)
    interval = start_date.beginning_of_day.utc..end_date.end_of_day.utc

    stats = Activity.unscoped.where(
      key: ["subscription.create", "subscription.destroy"],
      created_at: interval
    ).group("DATE(created_at)", :key, :recipient_id).count.each do |key, count|
      date, key, stack_id = key
      stats = StackStats.find_or_initialize_by(date: date, stack_id: stack_id)
      if key =~ /\.create/
        stats.subscriptions = count
      else key =~ /\.destroy/
           stats.unsubscriptions = count
      end
      stats.save
    end
  end
end
