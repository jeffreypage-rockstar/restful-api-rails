class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  enum role: [:user]
  after_initialize :set_default_role, if: :new_record?

  validates :username, uniqueness: true, allow_blank: true

  has_many :devices

  def set_default_role
    self.role ||= :user
  end

  def admin?
    true
  end

  def sign_in_from_device!(request, device_id, device_attrs = {})
    update_tracked_fields!(request)
    device = devices.find(device_id) if device_id
    device ||= devices.create!(device_attrs)
    device.sign_in!
  end
end
