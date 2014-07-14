class AddSecretToNetworks < ActiveRecord::Migration
  def change
    add_column :networks, :secret, :string
  end
end
