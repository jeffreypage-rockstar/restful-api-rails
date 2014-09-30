RailsAdmin.config do |config|
  stack_subscriptions_count_field = Proc.new do
    pretty_value do
      path = bindings[:view].rails_admin.index_path(
        model_name: "subscription",
        f: { stack_id: { "0001" => { v: bindings[:object].id } } }
      )
      bindings[:view].link_to(value, path).html_safe
    end
  end

  stack_stats_count_field = Proc.new do
    pretty_value do
      path = bindings[:view].rails_admin.index_path(
        model_name: "stack_stats",
        f: { stack_id: { "0001" => { v: bindings[:object].id } } }
      )
      bindings[:view].link_to(value, path).html_safe
    end
  end

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
      field :subscriptions_count, &stack_subscriptions_count_field
      field :stats_count, &stack_stats_count_field
      field :cards
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
      field :subscriptions_count, &stack_subscriptions_count_field
      field :stats_count, &stack_stats_count_field
      field :cards
    end
    edit do
      field :name
      field :description
      field :user
      field :protected
    end
  end
end
