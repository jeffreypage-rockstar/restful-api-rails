class Device < ActiveRecord::Base
  validates :user_id, presence: true

  belongs_to :user

  before_save :generate_access_token, on: :create
  after_save :register_sns
  after_destroy :unregister_sns

  scope :recent, -> do
    where.not(last_sign_in_at: nil).order("last_sign_in_at DESC")
  end

  scope :with_arn, -> { where.not(sns_arn: nil) }

  def sign_in!
    self.last_sign_in_at = Time.current
    self.save!
  end

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def register_sns
    DeviceRegisterWorker.perform_async(id) if push_token_changed?
  end

  def unregister_sns
    DeviceUnregisterWorker.perform_async(sns_arn) if sns_arn.present?
  end
end
