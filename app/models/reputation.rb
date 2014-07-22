class Reputation < ActiveRecord::Base
  validates :name, :min_score, presence: true, uniqueness: true

  default_scope { order(min_score: :desc) }
end
