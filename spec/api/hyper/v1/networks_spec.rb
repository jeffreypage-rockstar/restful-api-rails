require "spec_helper"

describe Hyper::V1::Networks do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:network) { create(:network, user: user, token: fb_token) }
  let(:fb_token) { Rails.application.secrets.fb_valid_token }
  let(:fb_uid) { Rails.application.secrets.fb_valid_user_id }

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
      VCR.use_cassette("fb_auth_valid") do
        http_login device.id, device.access_token
        post "/api/networks", attrs.merge(token: fb_token), @env
        r = JSON.parse(response.body)
        expect(response.status).to eql 201 # created
        provider = attrs[:provider]
        expect(r["provider"]).to eql provider
        expect(r["uid"]).to eql fb_uid
        expect(r["token"]).to eql fb_token
        expect(r["username"]).to eql attrs[:username]
        expect(r["user_id"]).to eql device.user_id
        expect(response.header["Location"]).to match "\/networks\/#{provider}"
      end
    end

    it "fails for an inexistent network provider" do
      http_login device.id, device.access_token
      post "/api/networks", attrs.merge(provider: network.provider), @env
      expect(response.status).to eql 409 # conflict
    end

    it "fails for an existent user with the same facebook id" do
      user_with_fb = create(:user_with_valid_fb)
      http_login device.id, device.access_token
      post "/api/networks", attrs.merge(provider: network.provider,
                                        uid: user_with_fb.facebook_id), @env
      expect(response.status).to eql 409 # conflict
    end

    it "fails when facebook authentication is not valid" do
      VCR.use_cassette("fb_auth_invalid") do
        http_login device.id, device.access_token
        post "/api/networks", attrs.merge(token: "invalidfacebooktoken"), @env
        r = JSON.parse(response.body)
        expect(response.status).to eql 422
        error = "token is invalid or does not allow publish_actions"
        expect(r["error"]).to match error
      end
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
      expect(r["username"]).to eql(network.username)
    end
  end

  # ======== UPDATING AN ASSOCIATED NETWORK ==================

  describe "PUT /api/networks/:provider" do
    it "requires authentication" do
      put "/api/networks/#{network.provider}", uid: "newuid"
      expect(response.status).to eql 401 # authentication
    end

    it "updates the network details" do
      VCR.use_cassette("fb_auth_valid") do
        http_login device.id, device.access_token
        put "/api/networks/#{network.provider}", { secret: "newsecret",
                                                   username: "newusername" },
            @env
        expect(response.status).to eql 200
        r = JSON.parse(response.body)
        expect(r["secret"]).to eql "newsecret"
        expect(r["username"]).to eql "newusername"
      end
    end

    it "fails when facebook authentication is not valid" do
      create(:network, provider: "facebook", user: user)
      VCR.use_cassette("fb_auth_invalid") do
        http_login device.id, device.access_token
        put "/api/networks/facebook", { token: "invalidfacebooktoken" }, @env
        expect(response.status).to eql 422
        r = JSON.parse(response.body)
        error = "token is invalid or does not allow publish_actions"
        expect(r["error"]).to match error
      end
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
