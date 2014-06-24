require_relative "base_auth_service"

class SignInService < BaseAuthService
  attr_accessor :username, :password, :facebook_token, :device_id, :device_type

  def initialize(remote_ip, auth_params = {})
    @remote_ip = remote_ip
    auth_params.each do |k, v|
      send("#{k}=", v) if respond_to?(k)
    end
  end

  def call
    if user = auth_user
      user.facebook_token = facebook_token if facebook_token.present?
      req = Hashie::Mash.new(remote_ip: @remote_ip)
      user.sign_in_from_device!(req, device_id, device_type: device_type)
      user
    end
  end

  private

  def auth_user
    if facebook_token.present?
      facebook_id = get_facebook_id(facebook_token)
      facebook_id.present? && User.find_by(facebook_id: facebook_id)
    else
      user = User.find_for_database_authentication(username: username)
      user.valid_password?(password) ? user : nil
    end
  end
end
