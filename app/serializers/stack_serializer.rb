class StackSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :protected
end
