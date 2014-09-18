class StackMenu
  PAGE = 1
  LIMIT = 10
  POPULAR_LIMIT = 30

  attr_accessor :subscribed_stacks, :owner_stacks, :popular_stacks

  def load(user)
    self.owner_stacks = user.stacks.recent.page(PAGE).per(LIMIT)
    self.subscribed_stacks = user.subscribed_stacks.recent
    self.popular_stacks = Stack.popular(user.id).page(PAGE).per(POPULAR_LIMIT)
    self
  end
end
