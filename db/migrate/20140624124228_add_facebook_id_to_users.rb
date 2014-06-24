class AddFacebookIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_id, :string

    remove_index :users, :facebook_token
    add_index :users, :facebook_id, unique: true
  end
end
