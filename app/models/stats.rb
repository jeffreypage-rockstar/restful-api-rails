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
    all
  end

  def self.weekly
    all
  end

  def self.monthly
    select("DATE_FORMAT(created_at, '%m%Y') as date, count(users) as users").
    group("period")
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
