class BaseAuthService
  protected

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
