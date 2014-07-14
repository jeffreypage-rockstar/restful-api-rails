require "spec_helper"

describe Hyper::Cards do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:card) { create(:card, user: user) }

  # ======== CREATING CARDS ==================
  describe "POST /api/cards" do
    it "requires authentication" do
      post "/api/cards",  name: "My card title", stack_id: card.stack_id
      expect(response.status).to eql 401 # authentication
      realm = "Basic realm=\"Hyper\""
      expect(response.header["WWW-Authenticate"]).to eql realm
    end

    it "creates a new valid card" do
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card title", stack_id: card.stack_id },
           @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r["name"]).to eql "My card title"
      card_id = r["id"]
      expect(card_id).to_not be_blank
      expect(r["stack_id"]).to eql card.stack_id
      expect(r["user_id"]).to eql device.user_id
      expect(r["images"]).to be_empty
      expect(response.header["Location"]).to match "\/cards\/#{card_id}"
    end

    it "creates a card with images" do
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card with images",
                           stack_id: card.stack_id,
                           images: [
                             { image_url: "http://example.com/image1.jpg",
                               caption: "Image 1"
                             },
                             { image_url: "http://example.com/image2.jpg",
                               caption: "Image 2"
                             }
                           ]
                         },
           @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r["name"]).to eql "My card with images"
      expect(r["images"].size).to eql 2
    end

    it "fails for an inexistent stack" do
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card title", stack_id: device.id }, @env
      expect(response.status).to eql 404 # not found
    end

    it "creates a card and share" do
      expect(ShareWorker).to receive(:perform_async).
                             with(user.id, /\w/, ["facebook", "twitter"])
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card title",
                           stack_id: card.stack_id,
                           share: ["facebook", "twitter"]
                          }, @env
      expect(response.status).to eql 201 # created
    end
  end

  # ======== GETTING CARDS ==================
  describe "GET /api/cards" do
    it "requires authentication" do
      get "/api/cards"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the newest cards" do
      create(:card, user: device.user)
      http_login device.id, device.access_token
      get "/api/cards", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
    end

    it "returns the stack cards" do
      create(:card, user: device.user, stack: card.stack)
      http_login device.id, device.access_token
      get "/api/cards", { stack_id: card.stack_id }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
      expect(r.map { |c|c["stack_id"] }.uniq).to eql [card.stack_id]
    end

    it "returns the stack cards ordered by popularity" do
      new_card = create(:card, user: device.user, stack: card.stack)
      new_card.vote_by!(device.user)
      http_login device.id, device.access_token
      get "/api/cards", { stack_id: card.stack_id, order_by: "popularity" },
          @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
      expect(r.first["id"]).to eql(new_card.id)
      expect(r.map { |c|c["score"] }.uniq).to eql [1, 0]
    end

    it "returns the user cards" do
      create(:card, user: device.user, stack: card.stack)
      http_login device.id, device.access_token
      get "/api/cards", { user_id: card.user_id }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
      expect(r.map { |c|c["user_id"] }.uniq).to eql [card.user_id]
    end

    it "accepts pagination" do
      (1..10).map { create(:card) }
      http_login device.id, device.access_token
      get "/api/cards", { page: 2, per_page: 3 }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(3)
      # response headers
      expect(response.header["Total"]).to eql("10")
      next_link = 'api/cards?page=3&per_page=3>; rel="next"'
      expect(response.header["Link"]).to include(next_link)
    end
  end

  # ======== GETTING A CARD DETAILS ==================

  describe "GET /api/cards/:id" do
    it "requires authentication" do
      get "/api/cards/#{card.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns a card details" do
      http_login device.id, device.access_token
      card.images << build(:card_image)
      card.save
      get "/api/cards/#{card.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(card.id)
      expect(r["images"]).to_not be_empty
    end

    it "returns flags_count and comments_count in response" do
      http_login device.id, device.access_token
      create(:comment, card: card)
      card.flag_by!(user)
      get "/api/cards/#{card.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(card.id)
      expect(r["flags_count"]).to eql 1
      expect(r["comments_count"]).to eql 1
    end

    it "returns my_vote with the card response" do
      http_login device.id, device.access_token
      card.vote_by!(user)
      get "/api/cards/#{card.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(card.id)
      expect(r["my_vote"]["kind"]).to eql "up"
      expect(r["my_vote"]["vote_score"]).to eql 1
    end
  end

  # ======== UPDATING A CARD ==================

  describe "PUT /api/cards/:id" do
    it "requires authentication" do
      new_stack = create(:stack)
      put "/api/cards/#{card.id}", name: "New card title",
                                   stack_id: new_stack.id
      expect(response.status).to eql 401 # authentication
    end

    it "updates the card details" do
      http_login device.id, device.access_token
      new_stack = create(:stack)
      put "/api/cards/#{card.id}", { name: "new card title",
                                     stack_id: new_stack.id },
          @env
      expect(response.status).to eql 204
    end

    it "does not allow other user update the card" do
      http_login device.id, device.access_token
      other_card = create(:card)
      put "/api/cards/#{other_card.id}", { name: "updated card title" }, @env
      expect(response.status).to eql 403 # forbidden
    end

    it "allows images inclusion" do
      card.images << build(:card_image)
      card.save
      http_login device.id, device.access_token
      put "/api/cards/#{card.id}", { images: [
        { image_url: "http://example.com/new_image.jpg",
          caption: "New Image"
        }
      ]
        }, @env
      expect(response.status).to eql 204
      card.images.reload
      expect(card.images.size).to eql 2
    end
  end

  # ======== DELETING A CARD ==================

  describe "DELETE /api/cards/:id" do
    it "requires authentication" do
      delete "/api/cards/#{card.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent card" do
      http_login device.id, device.access_token
      delete "/api/cards/#{user.id}", nil, @env
      expect(response.status).to eql 404
    end

    it "deletes an existent card" do
      http_login device.id, device.access_token
      delete "/api/cards/#{card.id}", nil, @env
      expect(response.status).to eql 204
    end

    it "does not allow other user delete the card" do
      http_login device.id, device.access_token
      other_card = create(:card)
      delete "/api/cards/#{other_card.id}", nil, @env
      expect(response.status).to eql 403 # forbidden
    end
  end

  # ======== POSTING A CARD VOTE ==================

  describe "POST /api/cards/:id/votes" do
    it "requires authentication" do
      post "/api/cards/#{card.id}/votes"
      expect(response.status).to eql 401 # authentication
    end

    it "requires a valid card id" do
      http_login device.id, device.access_token
      post "/api/cards/#{user.id}/votes", nil, @env
      expect(response.status).to eql 404 # not found
    end

    it "creates a new up_vote to the card as default" do
      http_login device.id, device.access_token
      post "/api/cards/#{card.id}/votes", nil, @env
      expect(response.status).to eql 201 # created
      r = JSON.parse(response.body)
      expect(r["user_id"]).to eql user.id
      expect(r["card_id"]).to eql card.id
      expect(r["vote_score"]).to eql 1
    end

    it "creates a new downvote to the card" do
      http_login device.id, device.access_token
      post "/api/cards/#{card.id}/votes", { kind: "down" }, @env
      expect(response.status).to eql 201 # created
      r = JSON.parse(response.body)
      expect(r["user_id"]).to eql user.id
      expect(r["card_id"]).to eql card.id
      expect(r["vote_score"]).to eql -1
    end
  end

  # ======== GETTING CARD VOTES ==================

  describe "GET /api/cards/:id/votes" do
    it "requires authentication" do
      get "/api/cards/#{card.id}/votes"
      expect(response.status).to eql 401 # authentication
    end

    it "requires a valid card id" do
      http_login device.id, device.access_token
      get "/api/cards/#{user.id}/votes", nil, @env
      expect(response.status).to eql 404 # not found
    end

    it "returns a card's list of votes" do
      card.vote_by!(user)
      other_user = create(:user)
      card.vote_by!(other_user, kind: "down")

      http_login device.id, device.access_token
      get "/api/cards/#{card.id}/votes", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql 2
      expect(r.map { |v| v["user_id"] }).to eql [other_user.id, user.id]
      expect(r.map { |v| v["card_id"] }.uniq).to eql [card.id]
      expect(r.map { |v| v["vote_score"] }).to eql [-1, 1]
    end
  end
end
