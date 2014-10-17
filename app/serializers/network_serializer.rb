class NetworkSerializer < ActiveModel::Serializer
  attributes :provider, :uid, :username, :token, :secret, :user_id, :updated_at
end
