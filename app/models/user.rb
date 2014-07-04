class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true,
                       uniqueness: true,
                       format: { with: /\A[a-z0-9_]*\z/ }
  validates :facebook_id, uniqueness: true, allow_blank: true
  validate :check_facebook_token

  has_many :devices
  has_many :stacks
  has_many :subscriptions
  has_many :subscribed_stacks, through: :subscriptions, source: :stack
  has_many :cards

  before_validation :downcase_username

  def sign_in_from_device!(request, device_id, device_attrs = {})
    update_tracked_fields!(request)
    device = devices.find(device_id) if device_id
    device ||= devices.create!(device_attrs)
    device.sign_in!
  end

  def title
    self.username
  end

  private

  def downcase_username
    self.username = username.to_s.downcase
  end

  def check_facebook_token
    if facebook_token.present? && facebook_id.blank?
      errors.add(:facebook_token, :invalid)
    end
  end

end
