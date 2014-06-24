class BaseAuthService
  protected

  def get_facebook_id(facebook_token)
    @graph = Koala::Facebook::API.new(
              facebook_token,
              Rails.application.secrets.facebook_app_secret)
    profile = @graph.debug_token(facebook_token)
    profile['data']['is_valid'] ? profile['data']['user_id'] : nil
  rescue Koala::Facebook::AuthenticationError
    nil
  end
end
