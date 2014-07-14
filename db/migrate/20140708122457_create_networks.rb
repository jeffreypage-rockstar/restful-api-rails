class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks, id: :uuid do |t|
      t.string :provider, null: false
      t.string :uid,      null: false
      t.string :token,    null: false
      t.uuid :user_id,  null: false

      t.timestamps
    end

    add_index :networks, [:provider, :user_id], unique: true
    add_index :networks, :uid
  end
end
