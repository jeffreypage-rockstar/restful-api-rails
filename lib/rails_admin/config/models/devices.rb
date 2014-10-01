RailsAdmin.config do |config|
  config.model "Device" do
    list do
      scopes [nil, :accepting_notification]
      field :user
      field :device_type
      field :push_token
      field :accept_notification?, :boolean
      field :last_sign_in_at do
        filterable true
      end
      field :created_at do
        filterable true
      end
      sort_by :last_sign_in_at
    end
    show do
      field :user
      field :device_type
      field :push_token
      field :sns_arn
      field :last_sign_in_at
      field :created_at
    end
    edit do
      field :user
      field :device_type
      field :push_token
      field :sns_arn
    end
  end
end
