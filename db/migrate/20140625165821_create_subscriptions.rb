class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.uuid :user_id,  null: false
      t.uuid :stack_id, null: false

      t.timestamps
    end

    add_index :subscriptions, [:user_id, :stack_id], unique: true
  end
end
