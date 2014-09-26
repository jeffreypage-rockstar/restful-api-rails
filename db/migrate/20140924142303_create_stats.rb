class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats, id: false do |t|
      t.date :date, null: false
      t.integer :users, default: 0
      t.integer :deleted_users, default: 0
      t.integer :stacks, default: 0
      t.integer :subscriptions, default: 0
      t.integer :cards, default: 0
      t.integer :comments, default: 0
      t.integer :flagged_users, default: 0
      t.integer :flagged_cards, default: 0
      t.integer :flagged_comments, default: 0
    end

    execute "ALTER TABLE stats ADD CONSTRAINT stats_pkey PRIMARY KEY (date);"
  end
end
