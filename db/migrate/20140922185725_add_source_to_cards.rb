class AddSourceToCards < ActiveRecord::Migration
  def change
    add_column :cards, :source, :string

    Card.update_all source: "device"

    change_column :cards, :source, :string, null: false
  end
end
