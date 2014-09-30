helper = RailsAdmin::ConfigHelper.new

RailsAdmin.config do |config|
  config.model "Comment" do
    object_label_method :body
    list do
      scopes [nil, :flagged]
      field :body
      field :score, &helper.score_field
      field :flags_count, &helper.flags_count_field
      field :replying
      field :card
      field :card_id, :enum do
        enum do
          Card.newest.limit(10).map { |c| [c.name, c.id] }
        end
        visible false
        searchable true
        queryable false
      end
      field :user
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end
    show do
      field :body
      field :score, &helper.score_field
      field :flags_count, &helper.flags_count_field
      field :replying
      field :card
      field :user
      field :created_at
    end
    edit do
      field :body
      field :score do
        read_only true
      end
      field :replying
      field :card
      field :user
      field :created_at
    end
  end
end
