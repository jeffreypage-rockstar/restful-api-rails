require "spec_helper"

describe Hyper::Flags do
  let(:device) { create(:device) }
  let(:user) { device.user }

  # ======== FLAGGING ==================
  describe "POST /api/flags" do
    it "requires authentication" do
      post "/api/flags"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent item" do
      http_login device.id, device.access_token
      post "/api/flags", { user_id: device.id }, @env
      expect(response.status).to eql 404
    end

    it "flags an existent user" do
      http_login device.id, device.access_token
      post "/api/flags", { user_id: user.id }, @env
      expect(response.status).to eql 204
    end

    it "flags an existent card" do
      card = create(:card)
      http_login device.id, device.access_token
      post "/api/flags", { card_id: card.id }, @env
      expect(response.status).to eql 204
    end

    it "requires a confirmed user to flag" do
      user.confirmed_at = nil
      user.save
      http_login device.id, device.access_token
      post "/api/flags", { user_id: user.id }, @env
      expect(response.status).to eql 403 # forbidden
      r = JSON.parse(response.body)
      expect(r["error"]).to match "need to confirm your email"
    end

    it "flags an existent comment" do
      comment = create(:comment)
      http_login device.id, device.access_token
      post "/api/flags", { comment_id: comment.id }, @env
      expect(response.status).to eql 204
    end

    it "does not accepts flagging 2 items in a request" do
      card = create(:card)
      comment = create(:comment, card: card)

      http_login device.id, device.access_token
      post "/api/flags", { comment_id: comment.id, card_id: card.id }, @env
      expect(response.status).to eql 400
      r = JSON.parse(response.body)
      expect(r["error"]).to match "mutually exclusive"
    end
  end
end
