class SignUpService
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

  private

  def get_facebook_id(facebook_token)
    @graph = Koala::Facebook::API.new(
              facebook_token,
              Rails.application.secrets.facebook_app_secret)
    profile = @graph.get_object('me')
    profile['id']
  rescue Koala::Facebook::AuthenticationError
    nil
  end
end
