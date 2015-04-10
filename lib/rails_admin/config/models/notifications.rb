RailsAdmin.config do |config|
  config.model "Notification" do
    list do
      scopes [nil, :sent, :not_sent, :seen, :unseen]
      field :caption
      field :user
      field :subject
      field :senders_count
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
      field :caption
      field :user
      field :subject
      field :senders_count
      field :created_at
      field :sent_at
      field :seen_at
      field :read_at
    end
  end
end
