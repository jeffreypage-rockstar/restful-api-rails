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

    it "requires a confirmed user" do
      Setting[:read_only_mode] = "enabled"
      user.confirmed_at = nil
      user.save
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card title", stack_id: card.stack_id },
           @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 # forbidden
      expect(r["error"]).to match "need to confirm your email"
    end

    it "does not require a confirmed user when setting is disabled" do
      Setting[:read_only_mode] = "disabled"
      user.confirmed_at = nil
      user.save
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card title", stack_id: card.stack_id },
           @env
      expect(response.status).to eql 201 # forbidden
    end

    it "creates a new valid card" do
      Setting[:read_only_mode] = "enabled"
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
                             { image_url: "http://example.com/image2.jpg"
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

    it "creates a card and auto subscribe" do
      expect(user.subscriptions.map(&:stack_id)).to_not include(card.stack_id)
      http_login device.id, device.access_token
      post "/api/cards", { name: "My card title", stack_id: card.stack_id },
           @env
      expect(response.status).to eql 201 # created
      user.reload
      expect(user.subscriptions.map(&:stack_id)).to include(card.stack_id)
    end
  end

  # ======== GETTING CARDS ==================
  describe "GET /api/cards" do
    let(:card_search_filter){ {include: :images, 
                               where: {},
                               order: {created_at: :desc}, 
                               page: 1,
                               per_page: nil}
                             }

    it "requires authentication" do
      get "/api/cards"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the newest cards" do
      card = create(:card, user: device.user)
      card.vote_by!(user)
      stream = mock_card_stream(Card.newest.map)
      http_login device.id, device.access_token
      get "/api/cards", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["total_entries"]).to eql(stream.total_entries)
      expect(r["cards"].size).to eql(1)
      expect(r["cards"].first["my_vote"]["kind"]).to eql("up")
      expect(r["scroll_id"]).to eql(stream.scroll_id)
    end

    it "returns the stack cards, sort by popularity" do
      stack = card.stack
      create(:card, user: user, stack: stack)
      stream = mock_card_stream(card.stack.cards, stack_id: stack.id,
                                                  order_by:"popularity")
      http_login device.id, device.access_token
      get "/api/cards", { stack_id: stack.id, order_by: "popularity" }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["total_entries"]).to eql(stream.total_entries)
      expect(r["cards"].size).to eql(2)
      expect(r["scroll_id"]).to eql(stream.scroll_id)
    end

    it "returns the user cards" do
      create(:card, user: device.user, stack: card.stack)
      stream = mock_card_stream(user.cards, user_id: card.user_id)
      
      http_login device.id, device.access_token
      get "/api/cards", { user_id: card.user_id }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["total_entries"]).to eql(stream.total_entries)
      expect(r["cards"].size).to eql(2)
      expect(r["cards"].first["user"]["username"]).to eql user.username
      expect(r["scroll_id"]).to eql(stream.scroll_id)
    end

    it "accepts a scroll_id to get next set" do
      (1..10).map { create(:card) }
      stream = mock_card_stream(Card.offset(2).limit(3), per_page: 3,
                                                         scroll_id: "nextid")
      
      http_login device.id, device.access_token
      get "/api/cards", { scroll_id: "nextid", per_page: 3 }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["total_entries"]).to eql(stream.total_entries)
      expect(r["cards"].size).to eql(3)
      expect(r["scroll_id"]).to eql(stream.scroll_id)
    end
  end

  # ======== GETTING UPVOTED CARDS ==================
  describe "GET /api/cards/upvoted" do
    it "requires authentication" do
      get "/api/cards/upvoted"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the latest upvoted cards by current user" do
      card.vote_by!(user)
      create(:card).vote_by!(user)
      http_login device.id, device.access_token
      get "/api/cards/upvoted", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
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

    it "requires a confirmed user to vote" do
      Setting[:read_only_mode] = "enabled"
      user.confirmed_at = nil
      user.save
      http_login device.id, device.access_token
      post "/api/cards/#{card.id}/votes", nil, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 # forbidden
      expect(r["error"]).to match "need to confirm your email"
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

  private

  def mock_card_stream(cards, params = {})
    stream = CardStreamService.new
    stream.cards = cards
    stream.total_entries = cards.size
    stream.scroll_id = "avalidscrollid"
    params = {order_by: "newest", per_page: 30}.merge(params)
    expect(stream).to receive(:execute).and_return(stream)
    expect(CardStreamService).to receive(:new).
                                 with(params).
                                 and_return(stream)
    stream
  end
end
