RailsAdmin.config do |config|
  config.model "Subscription" do
    list do
      field :user
      field :stack do
        filterable false
      end
      field :stack_id, :lookup
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
