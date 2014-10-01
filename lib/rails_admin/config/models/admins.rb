RailsAdmin.config do |config|
  config.model "Admin" do
    object_label_method :username
    list do
      field :email
      field :username
      field :last_sign_in_at do
        filterable true
      end
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end
    edit do
      field :email
      field :username
      field :password
      field :password_confirmation
    end
    show do
      field :email
      field :username
      field :last_sign_in_at
      field :created_at
    end
  end
end
