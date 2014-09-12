class AddExtraFieldToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :extra, :hstore
  end
end
