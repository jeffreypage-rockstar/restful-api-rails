require "spec_helper"

describe Hyper::Notifications do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:card) { create(:card, user: user, name: "card_name") }
  let(:notification) { create(:notification, user: user) }

  # ======== MARKING ALL AS SEEN ==================
  describe "DELETE /api/notifications" do
    it "requires authentication" do
      delete "/api/notifications/seen", before_id: notification.id
      expect(response.status).to eql 401 # authentication
      realm = "Basic realm=\"Hyper\""
      expect(response.header["WWW-Authenticate"]).to eql realm
    end

    it "requires a before_id param" do
      http_login device.id, device.access_token
      delete "/api/notifications/seen", nil, @env
      expect(response.status).to eql 400
    end

    it "marks all notifications as read" do
      http_login device.id, device.access_token
      delete "/api/notifications/seen", { before_id: notification.id }, @env
      expect(user.notifications.unseen.count).to eql 0
      expect(response.status).to eql 204 # empty body
    end
  end

  # ======== MARKING ALL AS READ ==================
  describe "DELETE /api/notifications" do
    it "requires authentication" do
      delete "/api/notifications/read", before_id: notification.id
      expect(response.status).to eql 401 # authentication
      realm = "Basic realm=\"Hyper\""
      expect(response.header["WWW-Authenticate"]).to eql realm
    end

    it "requires a before_id param" do
      http_login device.id, device.access_token
      delete "/api/notifications/read", nil, @env
      expect(response.status).to eql 400
    end

    it "marks all notifications as read" do
      http_login device.id, device.access_token
      delete "/api/notifications/read", { before_id: notification.id }, @env
      expect(user.notifications.unread.count).to eql 0
      expect(response.status).to eql 204 # empty body
    end
  end

  # ======== MARKING A SINGLE NOTIFICATION AS READ ==================
  describe "DELETE /api/notifications/:id" do
    it "requires authentication" do
      delete "/api/notifications/#{notification.id}"
      expect(response.status).to eql 401 # authentication
      realm = "Basic realm=\"Hyper\""
      expect(response.header["WWW-Authenticate"]).to eql realm
    end

    it "marks the notification as read" do
      http_login device.id, device.access_token
      delete "/api/notifications/#{notification.id}", nil, @env
      expect(user.notifications.unread.count).to eql 0
      expect(response.status).to eql 204 # empty body
    end
  end

  # ======== GETTING NOTIFICATIONS ==================
  describe "GET /api/notifications" do
    it "requires authentication" do
      get "/api/notifications"
      expect(response.status).to eql 401 # authentication
    end

    it "returns notifications read and unread, with extras" do
      (1..10).map do |i|
        create(:notification, user: user,
                              subject: card,
                              read_at: i.odd? ? Time.now.utc : nil,
                              action: "card.up_vote",
                              extra: {
                                card_id: card.id,
                                stack_id: card.stack_id
                              })
      end
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(10)
      expect(r.first["caption"]).to eql "A person upvoted your post "\
      "\"card_name\""
      expect(r.first["card_id"]).to eql card.id
      expect(r.first["stack_id"]).to eql card.stack_id
    end

    it "returns notifications with few senders" do
      senders = { "john" => 1, "peter" => 2, "michael" => 3 }
      create(:notification, user: user, subject: card, action: "card.up_vote",
                            senders: senders)
      create :card_image, card: card
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expected_caption = "john, peter and michael upvoted "\
      "your post \"card_name\""
      expect(r.first["caption"]).to eql expected_caption
    end

    it "returns notifications with many senders" do
      senders = { "john" => 1, "peter" => 2, "michael" => 3, "wendy" => 4 }
      create(:notification, user: user, subject: card, action: "card.up_vote",
             senders: senders)
      create :card_image, card: card
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expect(r.first["caption"]).to eql "4 people upvoted your post \"card_name\""
    end

    it "sends counts in header" do
      senders = { "john" => 1, "peter" => 2 }
      create(:notification, user: user, subject: card, action: "card.up_vote",
             senders: senders)
      create :card_image, card: card
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      expect(response.header["Total"]).to eq "1"
      expect(response.header["TotalUnseen"]).to eq "1"
    end
  end
end
