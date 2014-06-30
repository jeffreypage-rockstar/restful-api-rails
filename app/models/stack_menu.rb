class StackMenu
  PAGE = 1
  LIMIT = 10

  attr_accessor :subscribed_stacks, :owner_stacks, :trending_stacks

  def load(user)
    self.owner_stacks = user.stacks.recent.page(PAGE).per(LIMIT)
    self.subscribed_stacks = user.subscribed_stacks.recent.page(PAGE).per(LIMIT)
    self.trending_stacks = Stack.trending(user.id).page(PAGE).per(LIMIT)
    self
  end
end
