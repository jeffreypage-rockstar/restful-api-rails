class AddUpDownScoresToComments < ActiveRecord::Migration
  def change
    add_column :comments, :up_score, :integer, default: 0
    add_column :comments, :down_score, :integer, default: 0

    Comment.all.map(&:update_scores!)
  end
end
