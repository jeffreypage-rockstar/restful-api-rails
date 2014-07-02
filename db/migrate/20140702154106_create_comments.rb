class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, id: :uuid do |t|
      t.text :body
      t.hstore :mentions
      t.uuid :replying_id
      t.uuid :card_id,      null: false
      t.uuid :user_id,      null: false

      t.timestamps
    end

    add_index :comments, :card_id
    add_index :comments, :user_id
    add_index :comments, :replying_id
  end
end
