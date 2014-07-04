class Stack < ActiveRecord::Base
  validates :name, :user_id, presence: true

  validates_uniqueness_of :name

  belongs_to :user
  has_many :cards, dependent: :restrict_with_exception

  scope :recent, -> { order("created_at DESC") }

  # TODO: update this to return stacks ordered by points
  # TODO: do not return stacks users created or is already following
  # TODO: use the decay algorithm to return the sorted list
  def self.trending(user_id)
    where.not(user_id: user_id).recent
  end

  def user
    return nil if user_id.blank?
    super
  end
end
