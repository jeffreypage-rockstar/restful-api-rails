class UserShortSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :avatar_url, :location
end
