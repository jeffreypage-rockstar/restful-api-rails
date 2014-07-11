class Network < ActiveRecord::Base
  PROVIDERS = %w(facebook twitter tumblr)

  validates :user, :provider, :uid, :token, presence: true
  validates :provider, uniqueness: { scope: :user_id }, inclusion: PROVIDERS
  validates :secret, presence: true, if: Proc.new { |n| n.twitter? }

  before_validation :downcase_provider

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
end
