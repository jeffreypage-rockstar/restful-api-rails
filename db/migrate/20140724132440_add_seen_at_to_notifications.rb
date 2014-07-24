class AddSeenAtToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :seen_at, :datetime
    add_index :notifications, :seen_at
    add_index :notifications, :read_at
  end
end
