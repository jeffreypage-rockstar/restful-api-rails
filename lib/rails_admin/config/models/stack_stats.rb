RailsAdmin.config do |config|
  config.model "StackStats" do
    list do
      scopes [:daily, :weekly, :monthly]
      field :period do
        sortable true
        sort_reverse true
      end
      field :date do
        visible false
        filterable true
      end
      field :stack do
        sortable false
        filterable true
      end
      field :stack_id, :enum do
        enum do
          Stack.recent.limit(10).map { |s| [s.name, s.id] }
        end
        visible false
        searchable true
        queryable false
      end
      field :subscriptions
      field :unsubscriptions

      sort_by :period
      sort_without_tablename true
      items_per_page 100
      no_count_pagination true
    end
  end
end
