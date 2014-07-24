class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications, id: :uuid do |t|
      t.uuid :user_id,       null: false
      t.uuid :subject_id,    null: false
      t.string :subject_type,  null: false
      t.string :action,        null: false
      t.hstore :senders
      t.datetime :read_at
      t.datetime :sent_at

      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, [:subject_id, :subject_type]
  end
end
