RailsAdmin.config do |config|
  config.model "Reputation" do
    list do
      field :name
      field :min_score
    end
  end
end
