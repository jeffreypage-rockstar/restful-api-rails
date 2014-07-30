require "spec_helper"

describe Hyper::Stacks do
  let(:device) { create(:device) }
  let(:user) { device.user }

  # ======== CREATING STACKS ==================
  describe "POST /api/stacks" do
    it "requires authentication" do
      post "/api/stacks",  name: "My Stack Title"
      expect(response.status).to eql 401 # authentication
    end

    it "creates a new valid stack" do
      http_login device.id, device.access_token
      post "/api/stacks", {
        name: "MyStackTitle",
        description: "My Stack Description",
        protected: true
      }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r["name"]).to eql "MyStackTitle"
      expect(r["description"]).to eql "My Stack Description"
      stack_id = r["id"]
      expect(stack_id).to_not be_blank
      expect(r["protected"]).to eql true
      expect(r["user_id"]).to eql device.user_id
      expect(response.header["Location"]).to match "\/stacks\/#{stack_id}"
    end

    it "requires a unique stack title" do
      http_login device.id, device.access_token
      stack = create(:stack)
      post "/api/stacks", { name: stack.name }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 409 # conflict
      expect(r["status_code"]).to eql "conflict"
      expect(r["error"]).to match("name has already been taken")
    end

    it "requires a confirmed user as owner" do
      Setting[:read_only_mode] = "enabled"
      user.confirmed_at = nil
      user.save
      http_login device.id, device.access_token
      post "/api/stacks", {
        name: "MyStackTitle",
        description: "My Stack Description",
        protected: true
      }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 # forbidden
      expect(r["error"]).to match "need to confirm your email"
    end
  end

  # ======== GETTING USER STACKS ==================
  describe "GET /api/stacks" do
    it "requires authentication" do
      get "/api/stacks"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the current user stacks" do
      create(:stack, user: device.user)
      http_login device.id, device.access_token
      get "/api/stacks", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expect(r.first["user_id"]).to eql(device.user_id)
    end

    it "accepts pagination" do
      (1..10).map { create(:stack, user: device.user) }
      http_login device.id, device.access_token
      get "/api/stacks", { page: 2, per_page: 3 }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(3)
      # response headers
      expect(response.header["Total"]).to eql("10")
      next_link = 'api/stacks?page=3&per_page=3>; rel="next"'
      expect(response.header["Link"]).to include(next_link)
    end
  end

  # ======== GETTING TRENDING STACKS ==================
  describe "GET /api/stacks/trending" do
    it "requires authentication" do
      get "/api/stacks/trending", stacks: ["invalid"]
      expect(response.status).to eql 401 # authentication
    end

    it "returns the trending stacks for the current user" do
      create(:stack, user: device.user)
      other_stack = create(:stack)
      http_login device.id, device.access_token
      get "/api/stacks/trending", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expect(r.first["id"]).to eql other_stack.id
    end
  end

  # ======== GETTING STACKS FOR AUTOCOMPLETE ==================
  describe "GET /api/stacks/names" do
    it "requires authentication" do
      get "/api/stacks/names", q: "name"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the stacks with name matching the query, case insensitive" do
      stack = create(:stack)
      http_login device.id, device.access_token
      get "/api/stacks/names", { q: stack.name[0..2].upcase }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expect(r.first.keys).to eql(["id", "name", "subscriptions_count"])
    end
  end

  # ======== GETTING STACK LISTS FOR THE MENU ==================

  describe "GET /api/stacks/menu" do
    it "requires authentication" do
      get "/api/stacks/menu"
      expect(response.status).to eql 401 # authentication
    end

    it "returns an object with user onwed, subscribed and trending stacks" do
      stack = create(:stack, user: device.user)
      (1..25).map { create(:stack) } # stacks for trending
      (1..10).map { create(:subscription, user: device.user) }
      http_login device.id, device.access_token
      get "/api/stacks/menu", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["subscribed_to"]["stacks"].size).to eql 10
      expect(r["subscribed_to"]["more"]).to eql false
      expect(r["mine"]["stacks"].size).to eql 1
      expect(r["mine"]["stacks"].first["id"]).to eql stack.id
      expect(r["mine"]["more"]).to eql false
      expect(r["trending"]["stacks"].size).to eql 30
      expect(r["trending"]["more"]).to eql true
    end
  end

  # ======== GETTING A STACK DETAILS ==================

  describe "GET /api/stacks/:id" do
    it "requires authentication" do
      stack = create(:stack, user: device.user)
      get "/api/stacks/#{stack.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns a stack with related stacks list" do
      stack = create(:stack, user: device.user)
      http_login device.id, device.access_token
      get "/api/stacks/#{stack.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(stack.id)
    end

    it "requires an id in uuid format" do
      http_login device.id, device.access_token
      get "/api/stacks/invalid-format", nil, @env
      expect(response.status).to eql 400
      r = JSON.parse(response.body)
      expect(r["error"]).to match "uuid format"
    end
  end
end
