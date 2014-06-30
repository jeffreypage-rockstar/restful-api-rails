class FBAuthService
  def get_facebook_id(facebook_token)
    profile = graph.debug_token(facebook_token)
    profile["data"]["is_valid"] ? profile["data"]["user_id"] : nil
  rescue Koala::Facebook::AuthenticationError
    nil
  end

  def self.get_facebook_id(facebook_token)
    new.get_facebook_id(facebook_token)
  end

  def self.facebook_app_token
    @facebook_app_token ||= begin
      oauth = Koala::Facebook::OAuth.new(
                Rails.application.secrets.facebook_app_id,
                Rails.application.secrets.facebook_app_secret
              )
      oauth.get_app_access_token
    end
  end

  private

  def graph
    Koala::Facebook::API.new(self.class.facebook_app_token,
                             Rails.application.secrets.facebook_app_secret)
  end
end
