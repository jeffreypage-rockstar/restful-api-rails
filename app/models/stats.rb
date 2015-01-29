# CREATE TABLE stats (
#     date date NOT NULL,
#     users integer,
#     deleted_users integer,
#     stacks integer,
#     subscriptions integer,
#     cards integer,
#     comments integer,
#     flagged_users integer,
#     flagged_cards integer,
#     flagged_comments integer
# );

class Stats < ActiveRecord::Base
  self.table_name = :stats
  self.primary_key = :date

  validates :date, presence: true, uniqueness: true

  scope :latest, -> { order(date: :desc) }

  COUNTERS = %w(users deleted_users stacks subscriptions cards comments)
  FLAG_COUNTERS = %w(User Card Comment)

  def self.daily
    group_by_period("YYYY/MM/DD")
  end

  def self.weekly
    group_by_period("YYYY/MM (W)")
  end

  def self.monthly
    group_by_period("YYYY/MM")
  end

  def self.group_by_period(format)
    select_sql = <<-SQL
      to_char(date, '#{format}') as period,
      sum(users) as users,
      sum(deleted_users) as deleted_users,
      sum(stacks) as stacks,
      sum(subscriptions) as subscriptions,
      sum(cards) as cards,
      sum(comments) as comments,
      sum(flagged_users) as flagged_users,
      sum(flagged_cards) as flagged_cards,
      sum(flagged_comments) as flagged_comments
    SQL
    select(select_sql).group("period")
  end

  def self.generate(start_date, end_date)
    interval = start_date.beginning_of_day.utc..end_date.end_of_day.utc
    date_interval = interval.first.to_date..interval.last.to_date
    stats = date_interval.map { |date| Stats.find_or_initialize_by(date: date) }
    stats = stats.index_by(&:date)

    COUNTERS.each do |field, |
      load_counters(field, interval).each do |date, count|
        stats[date].send("#{field}=", count) if stats[date]
      end
    end

    FLAG_COUNTERS.each do |type|
      load_counters(:flags, interval, flaggable_type: type).
      each do |date, count|
        field = type.tableize
        stats[date].send("flagged_#{field}=", count) if stats[date]
      end
    end

    stats.values.flatten.map(&:save)
  end

  def self.load_counters(field, interval, conditions = {})
    klass = field.to_s.camelize.singularize.safe_constantize
    if klass
      klass.where(conditions.merge(created_at: interval)).
            group("DATE(created_at)").count
    else
      []
    end
  end
end
