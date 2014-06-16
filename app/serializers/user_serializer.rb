class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :confirmed, :auth

  def confirmed
    object.confirmed_at.present?
  end

  def auth
    if device = object.devices.recent.first
      { device_id: device.id, access_token: device.access_token }
    end
  end
end
