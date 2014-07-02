class AddScoreToComment < ActiveRecord::Migration
  def change
    add_column :comments, :score, :integer, default: 0
    add_index :comments, :score
  end
end
