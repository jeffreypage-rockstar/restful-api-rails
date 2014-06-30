class Subscription < ActiveRecord::Base
  validates :user_id, :stack_id, presence: true
  validates_uniqueness_of :stack_id, scope: :user_id, allow_blank: true,
                                     if: Proc.new { |u| u.user_id.present? }

  belongs_to :user
  belongs_to :stack

  scope :recent, -> { order("created_at DESC") }
end
