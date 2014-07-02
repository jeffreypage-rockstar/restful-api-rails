class StackSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :user_id, :protected, :updated_at,
             :created_at
end
