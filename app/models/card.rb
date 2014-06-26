class Card < ActiveRecord::Base
  validates :name, :stack_id, :user_id, presence: true

  belongs_to :stack
  belongs_to :user
  has_many :images, -> { order('position ASC') },
           class_name: 'CardImage',
           dependent: :destroy
end
