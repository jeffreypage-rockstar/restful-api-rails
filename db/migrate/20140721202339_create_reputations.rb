class CreateReputations < ActiveRecord::Migration
  def change
    create_table :reputations do |t|
      t.string :name,         null: false
      t.integer :min_score,    null: false

      t.timestamps
    end

    add_index :reputations, :name, unique: true
    add_index :reputations, :min_score, unique: true
  end
end
