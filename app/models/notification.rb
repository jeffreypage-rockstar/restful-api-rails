class Notification < ActiveRecord::Base
  validates :user, :subject, :action, presence: true
  store_accessor :senders

  belongs_to :user
  belongs_to :subject, polymorphic: true

  scope :unread, -> { where(read_at: nil).order(created_at: :desc) }

  def mask_as_read!
    self.read_at = Time.now.utc
    save
  end

  def read?
    read_at.present?
  end

  def self.mark_all_as_read(user_id)
    unread.where(user_id: user_id).update_all(read_at: Time.now.utc)
  end
end
