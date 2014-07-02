class AddDescriptionToStacks < ActiveRecord::Migration
  def change
    add_column :stacks, :description, :text
  end
end
