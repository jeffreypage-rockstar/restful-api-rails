helper = RailsAdmin::ConfigHelper.new

RailsAdmin.config do |config|
  config.model "User" do
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
    edit do
      field :email
      field :username
      field :location
      field :bio
      field :facebook_token
      field :facebook_id
    end
    show do
      field :email
      field :username
      field :location
      field :score
      field :bio
      field :stacks_count do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "stack",
            f: { user: { "0001" => { v: bindings[:object].username } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
      field :cards_count do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "card",
            f: { user: { "0001" => { v: bindings[:object].username } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
      field :comments_count do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "comment",
            f: { user: { "0001" => { v: bindings[:object].username } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
      field :flags_count, &helper.flags_count_field
      field :devices_count, &helper.devices_count_field
      field :last_sign_in_at
      field :confirmed_at
      field :networks, &helper.networks_field
      field :created_at
    end
  end
end
