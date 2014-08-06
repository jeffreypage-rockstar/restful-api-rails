class StackMenuSerializer < ActiveModel::Serializer
  attributes :subscribed_to, :mine, :trending

  def subscribed_to
    {
      stacks: object.subscribed_stacks.map do |s|
        StackShortSerializer.new(s, scope: current_user)
      end,
      more: object.subscribed_stacks.next_page.present?
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

  def trending
    {
      stacks: object.trending_stacks.map do |s|
        StackShortSerializer.new(s, scope: current_user)
      end,
      more: object.trending_stacks.next_page.present?
    }
  end
end
