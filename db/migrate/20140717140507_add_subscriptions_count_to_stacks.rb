class AddSubscriptionsCountToStacks < ActiveRecord::Migration
  def change
    add_column :stacks, :subscriptions_count, :integer, default: 0

    Stack.pluck(:id).map { |id| Stack.reset_counters id, :subscriptions }
  end
end
