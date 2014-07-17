class StackSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :user_id, :protected,
             :subscriptions_count, :updated_at, :created_at
end
