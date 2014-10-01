RailsAdmin.config do |config|
  config.model "Activity" do
    list do
      scopes [nil, :notified, :not_notified]
      field :key do
        pretty_value do
          case value
          when /\.destroy/
            %{<span class='label label-warning'>#{value}</span>}
          else
            %{<span class='label label-default'>#{value}</span>}
          end.html_safe
        end
      end
      field :trackable
      field :owner
      field :notified
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end

    show do
      field :key
      field :trackable
      field :owner
      field :notified
      field :created_at
    end
  end
end
