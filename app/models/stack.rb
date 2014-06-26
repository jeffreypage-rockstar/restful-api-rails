class Stack < ActiveRecord::Base
  validates :name, :user_id, presence: true

  validates_uniqueness_of :name

  belongs_to :user
  has_many :cards, dependent: :restrict_with_exception

  scope :recent, -> { order('created_at DESC') }
end
