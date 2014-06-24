require_relative "base_auth_service"

class SignUpService < BaseAuthService
  def initialize(user_attrs = {})
    @user = User.new(user_attrs)
  end

  def call
    if @user.facebook_token.present?
      @user.password ||= Devise.friendly_token[0, 20]
      @user.facebook_id = get_facebook_id(@user.facebook_token)
      @user.skip_confirmation!
    end
    @user.password_confirmation ||= @user.password
    @user.save!
    @user
  end
end
