class NetworkRegisterService
  def initialize(user, provider)
    @user = user
    @provider = provider.to_s.downcase
  end

  def register!(attrs = {})
    network = @user.networks.build(attrs)
    validate_facebook!(network) if network.valid? && network.facebook?
    network.save!
    network
  end

  def update!(attrs = {})
    network = @user.networks.find_by!(provider: @provider)
    attrs.delete(:provider)
    network.attributes = attrs
    validate_facebook!(network) if network.valid? && network.facebook?
    network.save!
    network
  end

  private

  def validate_facebook!(network)
    auth = FBAuthService.new(network.token)
    if auth.facebook_id && auth.can_publish?
      network.uid = auth.facebook_id
    else
      network.errors[:token] << "is invalid or does not allow publish_actions"
      raise ActiveRecord::RecordInvalid.new(network)
    end
  end
end
