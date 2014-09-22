class AddUploadedToCards < ActiveRecord::Migration
  def change
    add_column :cards, :uploaded, :boolean, default: false
  end
end
