RailsAdmin.config do |config|
  config.model "Subscription" do
    list do
      field :user
      field :stack
      field :stack_id, :enum do
        enum do
          Stack.recent.limit(10).map { |s| [s.name, s.id] }
        end
        visible false
        searchable true
        queryable false
      end
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end
    show do
      field :user
      field :stack
      field :created_at
    end
    edit do
      field :user
      field :stack
    end
  end
end
