namespace :hyper do
  desc "Update Stats table with latest data"
  task update_stats: [:environment] do
    StatsUpdaterWorker.new.perform
    StackStatsUpdaterWorker.new.perform
    puts "done."
  end
end
