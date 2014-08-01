class AddUpDownScoresToCards < ActiveRecord::Migration
  def change
    add_column :cards, :up_score, :integer, default: 0
    add_column :cards, :down_score, :integer, default: 0

    Card.all.map(&:update_scores!)
  end
end
