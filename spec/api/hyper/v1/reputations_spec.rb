require "spec_helper"

describe Hyper::V1::Reputations do
  let(:device) { create(:device) }
  let(:user) { device.user }

  describe "GET /api/reputations" do
    it "requires authentication" do
      get "/api/reputations"
      expect(response.status).to eql 401 # authentication
    end

    it "returns all reputations" do
      (1..10).each { create(:reputation) }
      http_login device.id, device.access_token
      get "/api/reputations", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql 10
    end
  end
end
