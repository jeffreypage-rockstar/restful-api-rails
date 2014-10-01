class CreateStackStats < ActiveRecord::Migration
  def change
    create_table :stack_stats, id: :uuid do |t|
      t.date :date, null: false
      t.uuid :stack_id, null: false
      t.integer :subscriptions, default: 0
      t.integer :unsubscriptions, default: 0
    end

    add_index :stack_stats, [:date, :stack_id], unique: true
  end
end
