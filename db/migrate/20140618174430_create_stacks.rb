class CreateStacks < ActiveRecord::Migration
  def change
    create_table :stacks, id: :uuid do |t|
      t.string  :name,        null: false
      t.boolean :protected,   null: false, default: false
      t.integer :user_id,     null: false
      
      t.timestamps
    end
    
    add_index :stacks, :name, unique: true
  end
end
