namespace :hyper do
  desc "Update Stats table with latest data"
  task clear_notifications: [:environment] do
    NotificationSender.
      joins(:notification).
      where("notification_senders.notification_id = notifications.id").
      where("notifications.created_at < ?", 1.days.ago).
      delete_all
    Notification.delete_all(["created_at < ?", 1.days.ago])
    puts "done."
  end
end
