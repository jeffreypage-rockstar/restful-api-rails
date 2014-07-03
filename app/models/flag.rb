class Flag < ActiveRecord::Base
  validates :user, :flaggable, presence: true

  validates :user_id, uniqueness: { scope: :flaggable_id }

  belongs_to :flaggable, polymorphic: true, counter_cache: true
  belongs_to :user
end
