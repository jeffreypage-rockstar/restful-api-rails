class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :avatar_url, :location, :score,
             :unseen_notifications_count, :unconfirmed_email, :confirmed,
             :flags_count, :auth

  def confirmed
    object.confirmed? && !object.pending_reconfirmation?
  end

  def auth
    if device = object.devices.recent.first
      { device_id: device.id, access_token: device.access_token }
    end
  end

  def unseen_notifications_count
    object.notifications.unseen.count
  end
end
