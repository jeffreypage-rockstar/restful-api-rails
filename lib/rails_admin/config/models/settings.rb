RailsAdmin.config do |config|
  config.model "Setting" do
    list do
      field :name
      field :value
      field :description
    end

    edit do
      field :name do
        read_only true
      end
      field :value
      field :description do
        read_only true
      end
    end
  end
end
