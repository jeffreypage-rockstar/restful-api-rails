class StackShortSerializer < ActiveModel::Serializer
  attributes :id, :name, :subscriptions_count, :subscribed

  def subscribed
    scope.subscriptions.exists?(stack_id: object.id)
  end
end
