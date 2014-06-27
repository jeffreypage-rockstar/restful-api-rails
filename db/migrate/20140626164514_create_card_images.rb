class CreateCardImages < ActiveRecord::Migration
  def change
    create_table :card_images, id: :uuid do |t|
      t.string :image_url, null: false
      t.text :caption
      t.uuid :card_id,   null: false
      t.integer :position

      t.timestamps
    end

    add_index :card_images, :card_id
  end
end
