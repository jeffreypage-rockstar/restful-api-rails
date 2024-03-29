class User < ActiveRecord::Base
  include Flaggable
  include PublicActivity::Model
  activist
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true,
                       uniqueness: true,
                       format: { with: /\A[a-z0-9_]*\z/ }
  validates :facebook_id, uniqueness: true, allow_blank: true
  validate :check_facebook_token

  scope :signup_with_facebook, -> { where.not(facebook_id: [nil, ""]) }

  has_many :devices, dependent: :destroy
  has_many :networks, dependent: :destroy
  has_many :stacks
  has_many :subscriptions
  has_many :subscribed_stacks, through: :subscriptions, source: :stack
  has_many :cards
  has_many :comments
  has_many :notifications
  has_many :votes

  after_save :update_facebook_network
  before_destroy :move_to_deleted

  def sign_in_from_device!(request, device_id, device_attrs = {})
    update_tracked_fields!(request)
    device = devices.find(device_id) if device_id
    device ||= devices.create!(device_attrs)
    device.sign_in!
  end

  def fb_signup?
    facebook_id.present?
  end

  def devices_count
    @devices_count ||= devices.count
  end

  def stacks_count
    @stacks_count ||= stacks.count
  end

  def cards_count
    @cards_count ||= cards.count
  end

  def comments_count
    @comments_count ||= comments.count
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

  def calculate_score
    self.score = cards.sum(:score) + comments.sum(:score)
  end

  def reset_unseen_notifications_count!
    update_column :unseen_notifications_count, notifications.unseen.count
  end

  protected # ================================================

  def move_to_deleted
    DeletedUser.create(attributes.merge(deleted_at: Time.now.utc))
  end

  private # ==================================================

  def check_facebook_token
    return unless facebook_token.present? && facebook_id.blank?
    errors.add(:facebook_token, :invalid)
  end

  def update_facebook_network
    return unless facebook_token_changed?
    network = networks.find_by(provider: "facebook")
    network.update_column(:token, facebook_token) if network
  end
end
