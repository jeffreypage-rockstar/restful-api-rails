class AddNotificationErrorToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :notification_error, :string
  end
end
