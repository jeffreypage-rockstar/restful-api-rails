class FBAuthService
  def initialize(facebook_token)
    @facebook_token = facebook_token
    @permissions = []
  end

  def facebook_id
    @facebook_id ||= begin
      profile["data"]["user_id"] if profile_valid?
    end
  end

  def permissions
    if @permissions.empty? && profile_valid?
      @permissions = profile["data"]["scopes"]
    end
    @permissions
  end

  def can_publish?
    permissions.include? "publish_actions"
  end

  def profile
    @profile ||= begin
      graph.debug_token(@facebook_token)
    rescue Koala::Facebook::AuthenticationError
      nil
    end
  end

  def profile_valid?
    profile && profile["data"]["is_valid"]
  end

  # CLASS METHODS =======================================================

  def self.get_facebook_id(facebook_token)
    new(facebook_token).facebook_id
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

  private # ============================================================

  def graph
    Koala::Facebook::API.new(self.class.facebook_app_token,
                             Rails.application.secrets.facebook_app_secret)
  end
end
