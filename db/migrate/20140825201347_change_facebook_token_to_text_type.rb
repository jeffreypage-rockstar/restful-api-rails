class ChangeFacebookTokenToTextType < ActiveRecord::Migration
  def change
    change_column :users, :facebook_token, :text
    change_column :networks, :token, :text
  end
end
