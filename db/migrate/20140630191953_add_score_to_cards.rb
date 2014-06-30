class AddScoreToCards < ActiveRecord::Migration
  def change
    add_column :cards, :score, :integer, default: 0
    add_index  :cards, :score
  end
end
