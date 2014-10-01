RailsAdmin.config do |config|
  config.model "Notification" do
    list do
      scopes [nil, :sent, :not_sent, :seen, :unseen]
      field :senders do
        formatted_value do
          (value || {}).map do |username, user_id|
            path = bindings[:view].rails_admin.
                                   show_path(model_name: "user", id: user_id)
            bindings[:view].link_to(username, path)
          end.join(", ").html_safe
        end
      end
      field :caption
      field :user
      field :subject
      field :created_at do
        filterable true
      end
      field :sent?, :boolean
      field :seen?, :boolean
      field :read?, :boolean
      field :sent_at do
        filterable true
      end
      sort_by :created_at
    end

    show do
      field :senders do
        formatted_value do
          (value || {}).map do |username, user_id|
            path = bindings[:view].rails_admin.
                                   show_path(model_name: "user", id: user_id)
            bindings[:view].link_to(username, path)
          end.join(", ").html_safe
        end
      end
      field :caption
      field :user
      field :subject
      field :created_at
      field :sent_at
      field :seen_at
      field :read_at
    end
  end
end
