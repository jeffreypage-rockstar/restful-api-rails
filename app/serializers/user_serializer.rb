class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :confirmed
  
  def confirmed
    object.confirmed_at.present?
  end
end
