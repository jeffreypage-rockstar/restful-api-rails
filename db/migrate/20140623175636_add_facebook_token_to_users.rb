class AddFacebookTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_token, :string

    add_index :users, :facebook_token
  end
end
