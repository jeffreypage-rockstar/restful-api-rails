require "spec_helper"

describe Hyper::Usernames do
  let(:device) { create(:device) }
  let(:user) { create(:user) }

  # ======== CHECKING AN AVAILABLE USERNAME ==================
  describe "GET /api/available-usernames/:username" do
    it "returns ok for an inexistent username" do
      get "/api/available-usernames/newusername"
      expect(response.status).to eql 200
    end

    it "returns not found for an existent username" do
      get "/api/available-usernames/#{user.username}"
      expect(response.status).to eql 404
    end
  end
end
