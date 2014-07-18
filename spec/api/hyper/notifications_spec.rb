require "spec_helper"

describe Hyper::Notifications do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:card) { create(:card, user: user) }

  # ======== MARKING AS READ ==================
  describe "POST /api/notifications" do
    it "requires authentication" do
      post "/api/notifications"
      expect(response.status).to eql 401 # authentication
      realm = "Basic realm=\"Hyper\""
      expect(response.header["WWW-Authenticate"]).to eql realm
    end

    it "marks all notifications as read" do
      expect(Notification).to receive(:mark_all_as_read).
                               with(user.id).once
      http_login device.id, device.access_token
      post "/api/notifications", nil, @env
      expect(response.status).to eql 204 # empty body
    end
  end

  # ======== GETTING NOTIFICATIONS ==================
  describe "GET /api/notifications" do
    it "requires authentication" do
      get "/api/notifications"
      expect(response.status).to eql 401 # authentication
    end

    it "returns unread notifications" do
      (1..10).map do
        create(:notification, user: user, subject: card, action: "card.up_vote")
      end
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(10)
      expect(r.first["caption"]).to eql "a person has liked your post"
    end

    it "returns unread notification with few senders" do
      senders = { "john" => 1, "peter" => 2, "michael" => 3 }
      create(:notification, user: user, subject: card, action: "card.up_vote",
                            senders: senders)

      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expected_caption = "john, peter, michael have liked your post"
      expect(r.first["caption"]).to eql expected_caption
    end

    it "returns unread notification with many senders" do
      senders = { "john" => 1, "peter" => 2, "michael" => 3, "wendy" => 4 }
      create(:notification, user: user, subject: card, action: "card.up_vote",
                            senders: senders)

      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expect(r.first["caption"]).to eql "4 people have liked your post"
    end
  end
end
