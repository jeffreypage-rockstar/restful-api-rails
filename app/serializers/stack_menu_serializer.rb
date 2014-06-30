class StackMenuSerializer < ActiveModel::Serializer
  attributes :subscribed_to, :mine, :trending

  def subscribed_to
    {
      stacks: object.subscribed_stacks.map { |s| StackShortSerializer.new(s) },
      more: object.subscribed_stacks.next_page.present?
    }
  end

  def mine
    {
      stacks: object.owner_stacks.map { |s| StackShortSerializer.new(s) },
      more: object.owner_stacks.next_page.present?
    }
  end

  def trending
    {
      stacks: object.trending_stacks.map { |s| StackShortSerializer.new(s) },
      more: object.trending_stacks.next_page.present?
    }
  end
end
