class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value
      t.text :description

      t.timestamps
    end
    add_index :settings, :key, unique: true
  end
end
