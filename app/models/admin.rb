class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :validatable

  validates :username, presence: true,
                       uniqueness: true,
                       format: { with: /\A[a-z0-9_]*\z/ }

  before_validation :downcase_username

  private

  def downcase_username
    self.username = username.to_s.downcase
  end
end
