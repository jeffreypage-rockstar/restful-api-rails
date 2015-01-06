# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec foreman run "\
                "rake :task"

every 5.minutes do
  rake "searchkick:reindex CLASS=Card"
end

every 1.hour do
  rake "hyper:update_stats"
end

every 1.day do
  rake "hyper:clear_notifications"
end
