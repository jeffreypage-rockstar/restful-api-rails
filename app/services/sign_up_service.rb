class SignUpService
  def initialize(user_attrs = {})
    @user = User.new(user_attrs)
  end

  def call
    if @user.facebook_token.present?
      @user.password ||= Devise.friendly_token[0, 20]
      fb_service = FBAuthService.new(@user.facebook_token)
      @user.facebook_id = fb_service.facebook_id
      @user.skip_confirmation!
      @user.add_facebook_network if fb_service.can_publish?
    end
    @user.password_confirmation ||= @user.password
    @user.save!
    @user
  end
end
