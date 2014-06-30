class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards, id: :uuid do |t|
      t.string :name,         null: false
      t.text :description
      t.uuid :stack_id,     null: false
      t.uuid :user_id,      null: false

      t.timestamps
    end

    add_index :cards, :stack_id
    add_index :cards, :user_id

    add_column :cards, :short_id, "SERIAL"
    add_index :cards, :short_id
  end
end
