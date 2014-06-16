class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer  :user_id,                    :null => false
      t.string   :access_token, :limit => 32, :null => false
      t.string   :device_type,  :limit => 16
      t.datetime :last_sign_in_at
      t.timestamps
    end
    
    add_index :devices, :user_id
    add_index :devices, :access_token, :unique => true
  end
end
