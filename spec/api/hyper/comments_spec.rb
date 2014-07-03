require "spec_helper"

describe Hyper::Cards do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:card) { create(:card, user: user) }
  let(:comment) { create(:comment, card: card, user: user) }

  # ======== CREATING CARD COMMENTS ==================
  describe "POST /api/cards/:card_id/comments" do
    it "requires authentication" do
      post "/api/cards/#{card.id}/comments", body: "My card comment"
      expect(response.status).to eql 401 # authentication
      expect(response.header["WWW-Authenticate"]).to eql "Basic realm=\"Hyper\""
    end

    it "creates a new valid comment" do
      http_login device.id, device.access_token
      parent = create(:comment, card: card)
      post "/api/cards/#{card.id}/comments", { body: "My card comment",
                                               replying_id: parent.id
                                              }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r["body"]).to eql "My card comment"
      comment_id = r["id"]
      expect(comment_id).to_not be_blank
      expect(r["card_id"]).to eql card.id
      expect(r["user_id"]).to eql device.user_id
      expect(r["replying_id"]).to eql parent.id
      expect(r["flags_count"]).to eql 0
      expect(r["score"]).to eql 0
      expect(response.header["Location"]).to match "\/comments\/#{comment_id}"
    end

    it "fails for an inexistent card" do
      http_login device.id, device.access_token
      post "/api/cards/#{device.id}/comments", { body: "My card comment" }, @env
      expect(response.status).to eql 404 # not found
    end
  end

  # ======== GETTING CARD COMMENTS ==================
  describe "GET /api/cards/:card_id/comments" do
    it "requires authentication" do
      get "/api/cards/#{card.id}/comments"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the newest comments for a card" do
      create(:comment, card: card)
      http_login device.id, device.access_token
      get "/api/cards/#{card.id}/comments", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
    end

    it "returns the card comments ordered by popularity" do
      new_comment = create(:comment, card: comment.card)
      new_comment.vote_by!(user)
      http_login device.id, device.access_token
      get "/api/cards/#{card.id}/comments", { order_by: "popularity" }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
      expect(r.first["id"]).to eql(new_comment.id)
      expect(r.map { |c|c["score"] }.uniq).to eql [1, 0]
    end

    it "returns the user comments for the card" do
      create(:comment, user: device.user, card: comment.card)
      http_login device.id, device.access_token
      get "/api/cards/#{card.id}/comments", { user_id: device.user_id }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
      expect(r.map { |c|c["user_id"] }.uniq).to eql [device.user_id]
    end

    it "accepts pagination" do
      (1..10).map { create(:comment, card: card) }
      http_login device.id, device.access_token
      get "/api/cards/#{card.id}/comments", { page: 2, per_page: 3 }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(3)
      # response headers
      expect(response.header["Total"]).to eql("10")
      link = "api/cards/#{card.id}/comments?page=3&per_page=3>; rel=\"next\""
      expect(response.header["Link"]).to include(link)
    end
  end

  # ======== GETTING A COMMENT DETAILS ==================

  describe "GET /api/comments/:id" do
    it "requires authentication" do
      get "/api/comments/#{comment.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "returns a comment details, including my vote" do
      http_login device.id, device.access_token
      comment.vote_by!(user)
      get "/api/comments/#{comment.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(comment.id)
      expect(r["score"]).to eql 1
      expect(r["my_vote"]["kind"]).to eql "up"
      expect(r["my_vote"]["vote_score"]).to eql 1
    end

    it "returns the comment details with mentions" do
      http_login device.id, device.access_token
      comment.body = "a comment replying @#{user.username}"
      comment.save
      get "/api/comments/#{comment.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(comment.id)
      expect(r["mentions"][user.username]).to eql user.id
    end
  end

  # ======== DELETING A COMMENT ==================

  describe "DELETE /api/comments/:id" do
    it "requires authentication" do
      delete "/api/comments/#{comment.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent comment" do
      http_login device.id, device.access_token
      delete "/api/comments/#{user.id}", nil, @env
      expect(response.status).to eql 404
    end

    it "deletes an existent comment" do
      http_login device.id, device.access_token
      delete "/api/comments/#{comment.id}", nil, @env
      expect(response.status).to eql 204
    end

    it "does not allow other user delete the card" do
      http_login device.id, device.access_token
      other_comment = create(:comment)
      delete "/api/comments/#{other_comment.id}", nil, @env
      expect(response.status).to eql 403 # forbidden
    end
  end

  # ======== POSTING A COMMENT VOTE ==================

  describe "POST /api/comments/:id/votes" do
    it "requires authentication" do
      post "/api/comments/#{comment.id}/votes"
      expect(response.status).to eql 401 # authentication
    end

    it "requires a valid comment id" do
      http_login device.id, device.access_token
      post "/api/comments/#{user.id}/votes", nil, @env
      expect(response.status).to eql 404 # not found
    end

    it "creates a new up_vote to the comment as default" do
      http_login device.id, device.access_token
      post "/api/comments/#{comment.id}/votes", nil, @env
      expect(response.status).to eql 201 # created
      r = JSON.parse(response.body)
      expect(r["user_id"]).to eql user.id
      expect(r["comment_id"]).to eql comment.id
      expect(r["vote_score"]).to eql 1
    end

    it "creates a new downvote to the card" do
      http_login device.id, device.access_token
      post "/api/comments/#{comment.id}/votes", { kind: "down" }, @env
      expect(response.status).to eql 201 # created
      r = JSON.parse(response.body)
      expect(r["user_id"]).to eql user.id
      expect(r["comment_id"]).to eql comment.id
      expect(r["vote_score"]).to eql -1
    end
  end

  # ======== GETTING COMMENT VOTES ==================

  describe "GET /api/comments/:id/votes" do
    it "requires authentication" do
      get "/api/comments/#{comment.id}/votes"
      expect(response.status).to eql 401 # authentication
    end

    it "requires a valid comment id" do
      http_login device.id, device.access_token
      get "/api/comments/#{user.id}/votes", nil, @env
      expect(response.status).to eql 404 # not found
    end

    it "returns a comment's list of votes" do
      comment.vote_by!(user)
      other_user = create(:user)
      comment.vote_by!(other_user, kind: "down")

      http_login device.id, device.access_token
      get "/api/comments/#{comment.id}/votes", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql 2
      expect(r.map { |v| v["user_id"] }).to eql [other_user.id, user.id]
      expect(r.map { |v| v["comment_id"] }.uniq).to eql [comment.id]
      expect(r.map { |v| v["vote_score"] }).to eql [-1, 1]
    end
  end
end
