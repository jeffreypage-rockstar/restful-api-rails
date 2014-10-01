require "rails_helper"

RSpec.describe Admin::ChartsController, type: "controller" do
  describe "GET users" do
    it "requires admin authentication" do
      get :users
      expect(response).to redirect_to(new_admin_session_path)
    end

    it "renders a json with the expected keys" do
      sign_in create(:admin)
      get :users
      expect(response.status).to eq(200)
      r = JSON.parse(response.body)
      expect(r.size).to eql 2
      expect(r.first["name"]).to match "New Users"
      expect(r.second["name"]).to match "Deleted Users"
    end
  end
end
