class Stack < ActiveRecord::Base
  validates :name, :user_id, presence: true

  validates_uniqueness_of :name

  belongs_to :user

  scope :recent, -> { order('created_at DESC') }
end
