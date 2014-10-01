RailsAdmin.config do |config|
  config.model "Vote" do
    list do
      scopes [nil, :up_votes, :down_votes]
      field :votable
      field :votable_type do
        filterable true
      end
      field :flag
      field :votable_id, :enum do
        enum do
          []
        end
        visible false
        searchable true
        queryable false
      end
      field :user do
        filterable true
      end
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end

    show do
      field :votable
      field :votable_type
      field :flag
      field :weight
      field :user
      field :created_at
    end

    edit do
      field :votable
      field :flag
      field :user
      field :weight
    end
  end
end
