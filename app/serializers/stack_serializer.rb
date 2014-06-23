class StackSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :protected, :updated_at, :created_at
end
