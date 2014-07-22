class AddScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :score, :integer, default: 0

    User.all.each do |user|
      user.calculate_score
      user.save(validate: false)
    end
  end
end
