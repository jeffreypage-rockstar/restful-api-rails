class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes, id: :uuid do |t|
      t.uuid :votable_id,    null: false
      t.string :votable_type,  null: false
      t.uuid :user_id,       null: false
      t.boolean :flag,          default: true # up/down
      t.integer :weight,        default: 1

      t.timestamps
    end

    add_index :votes, [:votable_id, :votable_type, :user_id], unique: true
  end
end
