class AddImageToCardImages < ActiveRecord::Migration
  def change
    add_column :card_images, :image, :string
  end
end
