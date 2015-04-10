namespace :hyper do
  desc "Update Stats table with latest data"
  task migrate_notifications: [:environment] do
    puts "moving old_notifications to new table"
    total = OldNotification.count
    current = 0
    OldNotification.find_in_batches(batch_size: 1000) do |group|
      notifications = []
      notification_senders = []
      group.each do |o|
        attrs = o.attributes
        senders = attrs.delete("senders")
        attrs[:read] = attrs.delete("read_at").present?
        attrs[:seen] = attrs.delete("seen_at").present?
        attrs[:extra_raw] = o.extra
        attrs.delete("extra")
        attrs[:senders_count] = senders.keys.size
        notifications << Notification.new(attrs)
        notification_senders += senders.invert.map do |user_id, username|
          NotificationSender.new(notification_id: attrs["id"],
                                 username: username,
                                 user_id: user_id)
        end
      end
      begin
        Notification.import notifications, validate: false
        NotificationSender.import notification_senders, validate: false
      rescue => e
        puts e.message
        puts e.backtrace
      end
      current += 1000
      puts "moved #{current}/#{total}"
    end
    puts "done."
  end
end
