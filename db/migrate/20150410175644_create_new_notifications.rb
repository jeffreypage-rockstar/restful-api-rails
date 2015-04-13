class CreateNewNotifications < ActiveRecord::Migration
  def change
    rename_table :notifications, :old_notifications
    create_table :notifications, id: :uuid do |t|
      t.uuid :user_id,         null: false
      t.uuid :subject_id,      null: false
      t.string :subject_type,  null: false
      t.string :action,        null: false
      t.boolean :seen,         default: false
      t.boolean :read,         default: false
      t.datetime :sent_at
      t.string :extra
      t.integer :senders_count, default: 0

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, [:subject_id, :subject_type]
    add_index :notifications, :action

    create_table :notification_senders do |t|
      t.uuid :notification_id, null: false
      t.uuid :user_id,  null: false
      t.string :username, null: false
    end

    add_index :notification_senders, :notification_id
    add_index :notification_senders, [:notification_id, :user_id], unique: true
  end
end
