class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :avatar_url, :unconfirmed_email,
             :confirmed, :auth

  def confirmed
    object.confirmed? && !object.pending_reconfirmation?
  end

  def auth
    if device = object.devices.recent.first
      { device_id: device.id, access_token: device.access_token }
    end
  end
end
