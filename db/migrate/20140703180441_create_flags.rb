class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags, id: :uuid do |t|
      t.uuid :flaggable_id,    null: false
      t.string :flaggable_type,  null: false
      t.uuid :user_id,        null: false
      t.integer :kind,           default: 0

      t.timestamps
    end

    add_index :flags, [:flaggable_id, :flaggable_type, :user_id], unique: true
  end
end
