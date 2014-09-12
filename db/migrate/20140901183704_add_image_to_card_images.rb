class AddImageToCardImages < ActiveRecord::Migration
  def change
    add_column :card_images, :image, :string
    add_column :card_images, :image_processing, :boolean, default: false
    rename_column :card_images, :image_url, :original_image_url
  end
end
