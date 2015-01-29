namespace :hyper do
  desc "Update Stats table with latest data"
  task clear_notifications: [:environment] do
    Notification.delete_all(["created_at < ?", 1.days.ago])
    puts "done."
  end
end
