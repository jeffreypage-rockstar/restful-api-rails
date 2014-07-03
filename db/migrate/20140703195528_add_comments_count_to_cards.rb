class AddCommentsCountToCards < ActiveRecord::Migration
  def change
    add_column :cards, :comments_count, :integer, default: 0

    Card.pluck(:id).map { |id| Card.reset_counters id, :comments }
  end
end
