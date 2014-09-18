class StackMenuSerializer < ActiveModel::Serializer
  attributes :subscribed_to, :mine, :trending, :popular

  def subscribed_to
    {
      stacks: object.subscribed_stacks.map do |s|
        StackShortSerializer.new(s, scope: current_user)
      end,
      more: false
    }
  end

  def mine
    {
      stacks: object.owner_stacks.map do |s|
        StackShortSerializer.new(s, scope: current_user)
      end,
      more: object.owner_stacks.next_page.present?
    }
  end

  def popular
    {
      stacks: object.popular_stacks.map do |s|
        StackShortSerializer.new(s, scope: current_user)
      end,
      more: object.popular_stacks.next_page.present?
    }
  end

  # DEPRECATED: remove later
  def trending
    {
      stacks: [],
      more: false
    }
  end
end
