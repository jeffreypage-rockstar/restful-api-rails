RailsAdmin.config do |config|
  config.model "Flag" do
    list do
      field :flaggable
      field :flaggable_type, :enum do
        enum do
          ["User", "Card", "Comment"]
        end
        filterable true
      end
      field :flaggable_id, :enum do
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
      field :flaggable
      field :flaggable_type
      field :user
      field :created_at
    end
  end
end
