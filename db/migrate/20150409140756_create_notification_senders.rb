class CreateNotificationSenders < ActiveRecord::Migration
  def change
    add_column :notifications, :senders_count, :integer, default: 0

    create_table :notification_senders do |t|
      t.uuid :notification_id, null: false
      t.uuid :user_id,  null: false
      t.text :username, null: false
    end

    add_index :notification_senders, :notification_id
    add_index :notification_senders, [:notification_id, :user_id], unique: true

    Notification.find_each do |notification|
      if notification[:senders]
        senders = []
        notification[:senders].each do |username, user_id|
          senders << { username: username, user_id: user_id }
        end
        notification.senders.create(senders)
      end
    end

    remove_column :notifications, :senders
  end
end
