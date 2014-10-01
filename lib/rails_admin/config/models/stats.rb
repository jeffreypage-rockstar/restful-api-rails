RailsAdmin.config do |config|
  stats_field_count = Proc.new do
    column_width 60
  end
  config.model "Stats" do
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
      field :users, &stats_field_count
      field :deleted_users, &stats_field_count
      field :stacks, &stats_field_count
      field :subscriptions, &stats_field_count
      field :cards, &stats_field_count
      field :comments, &stats_field_count
      field :flagged_users, &stats_field_count
      field :flagged_cards, &stats_field_count
      field :flagged_comments, &stats_field_count

      sort_by :period
      sort_without_tablename true
      items_per_page 100
      no_count_pagination true
    end
  end
end
