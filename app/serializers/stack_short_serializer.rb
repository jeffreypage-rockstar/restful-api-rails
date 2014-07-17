class StackShortSerializer < ActiveModel::Serializer
  attributes :id, :name, :subscriptions_count
end
