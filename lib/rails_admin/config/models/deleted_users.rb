helper = RailsAdmin::ConfigHelper.instance

RailsAdmin.config do |config|
  config.model "DeletedUser" do
    object_label_method :username
    list do
      scopes [nil, :flagged, :signup_with_facebook]
      field :email
      field :username
      field :location
      field :score
      field :fb_signup?, :boolean
      field :last_sign_in_at do
        filterable true
      end
      field :flags_count, &helper.flags_count_field
      field :confirmed_at
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end
    show do
      field :email
      field :username
      field :location
      field :score
      field :bio
      field :flags_count, &helper.flags_count_field
      field :last_sign_in_at
      field :confirmed_at
      field :created_at
    end
    edit do
      field :email
      field :username
      field :location
      field :facebook_token
      field :facebook_id
    end
  end
end
