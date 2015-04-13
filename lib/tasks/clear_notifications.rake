namespace :hyper do
  desc "Update Stats table with latest data"
  task clear_notifications: [:environment] do
    notifications = Notification.where(["created_at < ?", 1.days.ago])
    total = notifications.count
    current = 0
    notifications.find_in_batches(batch_size: 1000) do |group|
      ids = group.map(&:id)
      current += ids.size
      puts "removing #{current}/#{total}"
      Notification.transaction do
        NotificationSender.delete_all(notification_id: ids)
        Notification.delete_all(id: ids)
      end
    end
    puts "done."
  end
end
