class StackShortSerializer < ActiveModel::Serializer
  attributes :id, :name, :subscriptions_count, :subscribed

  def subscribed
    current_user.subscriptions.exists?(stack_id: object.id)
  end
end
