class User < ActiveRecord::Base
  include Flaggable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true,
                       uniqueness: true,
                       format: { with: /\A[a-z0-9_]*\z/ }
  validates :facebook_id, uniqueness: true, allow_blank: true
  validate :check_facebook_token

  has_many :devices, dependent: :destroy
  has_many :networks, dependent: :destroy
  has_many :stacks
  has_many :subscriptions
  has_many :subscribed_stacks, through: :subscriptions, source: :stack
  has_many :cards

  after_save :update_facebook_network

  def sign_in_from_device!(request, device_id, device_attrs = {})
    update_tracked_fields!(request)
    device = devices.find(device_id) if device_id
    device ||= devices.create!(device_attrs)
    device.sign_in!
  end

  def title
    username
  end

  def add_facebook_network
    return if facebook_token.blank?
    networks.find_or_initialize_by(provider: "facebook").tap do |network|
      network.token = facebook_token
      network.uid = facebook_id
    end
  end

  def subscribe(stack)
    subscriptions.find_or_create_by(stack: stack)
  end

  private

  def check_facebook_token
    return unless facebook_token.present? && facebook_id.blank?
    errors.add(:facebook_token, :invalid)
  end

  def update_facebook_network
    return unless facebook_token_changed?
    network = networks.find_by(provider: "facebook")
    network.update_attribute(:token, facebook_token) if network
  end
end
