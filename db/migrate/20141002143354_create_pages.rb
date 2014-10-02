class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages, id: :uuid do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :content

      t.timestamps
    end

    add_index :pages, :slug, unique: true
  end
end
