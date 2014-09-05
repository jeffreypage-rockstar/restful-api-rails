require "spec_helper"

describe Hyper::Networks do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:network) { create(:network, user: user) }

  # ======== ASSOCIATING NETWORKS ==================
  describe "POST /api/networks" do
    let(:attrs) { attributes_for(:network) }

    it "requires authentication" do
      post "/api/networks",  attrs
      expect(response.status).to eql 401 # authentication
      realm = "Basic realm=\"Hyper\""
      expect(response.header["WWW-Authenticate"]).to eql realm
    end

    it "associates a new valid network" do
      http_login device.id, device.access_token
      post "/api/networks", attrs, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      provider = attrs[:provider]
      expect(r["provider"]).to eql provider
      expect(r["uid"]).to eql attrs[:uid]
      expect(r["token"]).to eql attrs[:token]
      expect(r["user_id"]).to eql device.user_id
      expect(response.header["Location"]).to match "\/networks\/#{provider}"
    end

    it "fails for an inexistent network provider" do
      http_login device.id, device.access_token
      post "/api/networks", attrs.merge(provider: network.provider), @env
      expect(response.status).to eql 409 # conflict
    end
  end

  # ======== GETTING USER ASSOCIATED NETWORKS ==================
  describe "GET /api/networks" do
    it "requires authentication" do
      get "/api/networks"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the user networks" do
      Network::PROVIDERS.map { |p| create(:network, user: user, provider: p) }
      http_login device.id, device.access_token
      get "/api/networks", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(Network::PROVIDERS.size)
      expect(r.map { |c|c["user_id"] }.uniq).to eql [user.id]
    end
  end

  # ======== GETTING A USER NETWORK DETAILS ==================

  describe "GET /api/networks/:provider" do
    it "requires authentication" do
      get "/api/networks/#{network.provider}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns a network details" do
      http_login device.id, device.access_token
      get "/api/networks/#{network.provider}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(network.id)
    end
  end

  # ======== UPDATING AN ASSOCIATED NETWORK ==================

  describe "PUT /api/networks/:id" do
    it "requires authentication" do
      put "/api/networks/#{network.provider}", uid: "newuid"
      expect(response.status).to eql 401 # authentication
    end

    it "updates the network details" do
      http_login device.id, device.access_token
      put "/api/networks/#{network.provider}", { uid: "newuid" }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["uid"]).to eql "newuid"
    end
  end

  # ======== DELETING ASSOCIATED AN ASSOCIATED NETWORK ==================

  describe "DELETE /api/networks/:provider" do
    it "requires authentication" do
      delete "/api/networks/#{network.provider}"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent network" do
      http_login device.id, device.access_token
      delete "/api/networks/invalid", nil, @env
      expect(response.status).to eql 404
    end

    it "deletes an existent network" do
      http_login device.id, device.access_token
      delete "/api/networks/#{network.provider}", nil, @env
      expect(response.status).to eql 204
    end
  end
end
