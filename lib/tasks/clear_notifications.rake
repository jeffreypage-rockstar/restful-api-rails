namespace :hyper do
  desc "Update Stats table with latest data"
  task clear_notifications: [:environment] do
    Notification.delete_all(["created_at < ?", 2.weeks.ago])
    puts "done."
  end
end
