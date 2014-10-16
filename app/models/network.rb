class Network < ActiveRecord::Base
  PROVIDERS = %w(facebook twitter tumblr)

  validates :user, :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: :user_id }, inclusion: PROVIDERS
  validates :secret, presence: true, if: Proc.new { |n| !n.facebook? }

  before_validation :downcase_provider
  validate :unique_facebook_uid
  after_save :update_user_token
  after_destroy :remove_user_token

  belongs_to :user

  PROVIDERS.each do |p|
    define_method "#{p}?" do
      provider == p
    end
  end

  private

  def downcase_provider
    self.provider = provider.to_s.downcase
  end

  def unique_facebook_uid
    return unless facebook?
    return unless user.try(:persisted?)
    return unless User.where.not(id: user_id).where(facebook_id: uid).exists?
    errors.add(:uid, :taken)
  end

  def update_user_token
    return unless facebook?
    return if user.nil? || user.facebook_id.present?
    user.update_columns(facebook_id: uid, facebook_token: token)
  end

  def remove_user_token
    return unless facebook?
    user.update_columns(facebook_id: nil, facebook_token: nil)
  end
end
