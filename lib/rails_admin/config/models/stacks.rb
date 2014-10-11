helper = RailsAdmin::ConfigHelper.instance

RailsAdmin.config do |config|
  config.model "Stack" do
    list do
      field :display_name
      field :name do
        visible false
        searchable true
      end
      field :description
      field :user
      field :protected
      field :subscriptions_count, &helper.lookup_link("subscription", :stack_id)
      field :stats_count, &helper.lookup_link("stack_stats", :stack_id)
      field :cards_count, &helper.lookup_link("card", :stack_id)
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end
    show do
      field :display_name
      field :description
      field :user
      field :protected
      field :subscriptions_count, &helper.lookup_link("subscription", :stack_id)
      field :stats_count, &helper.lookup_link("stack_stats", :stack_id)
      field :cards_count, &helper.lookup_link("card", :stack_id)
    end
    edit do
      field :name
      field :description
      field :user
      field :protected
    end
  end
end
