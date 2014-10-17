class AddUsernameToNetworks < ActiveRecord::Migration
  def change
    add_column :networks, :username, :string
  end
end
