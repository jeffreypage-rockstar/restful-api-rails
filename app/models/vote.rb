class Vote < ActiveRecord::Base
  validates :votable, :user, presence: true

  validates_uniqueness_of :user_id, scope: :votable_id

  belongs_to :votable, polymorphic: true
  belongs_to :user
end
