class Network < ActiveRecord::Base
  PROVIDERS = %w(facebook twitter tumblr)

  validates :user, :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: :user_id }, inclusion: PROVIDERS

  before_validation :downcase_provider

  belongs_to :user

  private

  def downcase_provider
    self.provider = provider.to_s.downcase
  end
end
