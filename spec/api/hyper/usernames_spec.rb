require "spec_helper"

describe Hyper::Usernames do
  let(:device) { create(:device) }
  let(:user) { create(:user) }

  # ======== GETTING A USERNAME ==================
  describe "GET /api/usernames/:username" do
    it "requires authentication" do
      get "/api/usernames/#{user.username}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns ok for an existent username" do
      http_login device.id, device.access_token
      get "/api/usernames/#{user.username}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["username"]).to eql(user.username)
    end

    it "returns not found for an inexistent username" do
      http_login device.id, device.access_token
      get "/api/usernames/invalid", nil, @env
      expect(response.status).to eql 404
    end
  end

  # ======== CHECKING AN AVAILABLE USERNAME ==================
  describe "GET /api/available-usernames/:username" do
    it "requires authentication" do
      get "/api/available-usernames/#{user.username}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns ok for an inexistent username" do
      http_login device.id, device.access_token
      get "/api/available-usernames/newusername", nil, @env
      expect(response.status).to eql 200
    end

    it "returns not found for an existent username" do
      http_login device.id, device.access_token
      get "/api/available-usernames/#{user.username}", nil, @env
      expect(response.status).to eql 404
    end
  end
end
