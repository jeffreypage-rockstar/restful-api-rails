class AddFlagsCountToUserCardComment < ActiveRecord::Migration
  def change
    add_column :users, :flags_count, :integer, default: 0
    add_column :cards, :flags_count, :integer, default: 0
    add_column :comments, :flags_count, :integer, default: 0
  end
end
