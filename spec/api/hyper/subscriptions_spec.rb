require "spec_helper"

describe Hyper::Subscriptions do
  let(:stack) { create(:stack) }
  let(:user) { create(:user) }
  let(:device) { create(:device, user: user) }

  # ======== SUBSCRIBING STACKS ==================
  describe "POST /api/subscriptions" do
    it "requires authentication" do
      post "/api/subscriptions",  stacks: stack.id
      expect(response.status).to eql 401 # authentication
    end

    it "subscribes the user to the stack" do
      http_login device.id, device.access_token
      post "/api/subscriptions", { stacks: stack.id }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r.size).to eql 1
      expect(r.first["stack_id"]).to eql stack.id
    end

    it "subscribes the user to a set of stacks" do
      other_stack = create(:stack)
      http_login device.id, device.access_token
      post "/api/subscriptions",
           { stacks: [stack.id,
                      other_stack.id,
                      "0f8c2ac0-a4d2-4482-abf2-000000000000"
                     ].join(",") },
           @env

      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r.size).to eql 2
      expect(r.map { |s| s["stack_id"] }).to eql [other_stack.id, stack.id]
    end
  end

  # ======== GETTING USER SUBSCRIPTIONS ==================
  describe "GET /api/subscriptions" do
    it "requires authentication" do
      get "/api/subscriptions"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the current user stacks" do
      create(:subscription, user: user, stack: stack)
      http_login device.id, device.access_token
      get "/api/subscriptions", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expect(r.first["id"]).to eql(stack.id)
    end

    it "accepts pagination" do
      (1..10).map { create(:subscription, user: user) }
      http_login device.id, device.access_token
      get "/api/subscriptions", { page: 2, per_page: 3 }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(3)
      # response headers
      expect(response.header["Total"]).to eql("10")
      next_link = 'api/subscriptions?page=3&per_page=3>; rel="next"'
      expect(response.header["Link"]).to include(next_link)
    end
  end

  # ======== UNSUBSCRIBING FROM A STACK ==================
  describe "delete /api/subscriptions/:stack_id" do
    it "requires authentication" do
      delete "/api/subscriptions/#{stack.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns error if not subscribed" do
      http_login device.id, device.access_token
      delete "/api/subscriptions/#{stack.id}", nil, @env
      expect(response.status).to eql 404 # not found
    end

    it "unsubscribe current user from the stack" do
      create(:subscription, user: user, stack: stack)
      http_login device.id, device.access_token
      delete "/api/subscriptions/#{stack.id}", nil, @env
      expect(response.status).to eql 204 # no content
    end
  end
end
