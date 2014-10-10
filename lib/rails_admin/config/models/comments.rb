helper = RailsAdmin::ConfigHelper.instance

RailsAdmin.config do |config|
  config.model "Comment" do
    object_label_method :body
    list do
      scopes [nil, :flagged]
      field :body
      field :score, &helper.score_field
      field :flags_count, &helper.flags_count_field
      field :replying
      field :card do
        filterable false
      end
      field :card_id, :lookup
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
