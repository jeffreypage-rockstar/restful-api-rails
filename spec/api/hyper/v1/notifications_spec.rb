require "spec_helper"

describe Hyper::V1::Notifications do
  let(:device) { create(:device) }
  let(:user) { device.user }
  let(:card) { create(:card, user: user, name: "card_name") }
  let(:notification) { create(:sent_notification, user: user) }

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
      expect(user.unseen_notifications_count).to eql 0
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
        create(:sent_notification,  user: user,
                                    subject: card,
                                    read: i.odd?,
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

    it "does not return not sent notifications" do
      create(:notification, user: user, subject: card)
      create(:sent_notification, user: user, subject: card)
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
    end

    it "returns notifications with few senders" do
      notification = create(:sent_notification, user: user, subject: card)
      senders = create_list(:sender, 3, notification: notification)
      create :card_image, card: card
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expected_caption = "user_name_1, user_name_2 and user_name_3 upvoted "\
      "your post \"card_name\""
      expect(r.first["caption"]).to eql expected_caption
      expect(r.first["senders"].values).to eql senders.map(&:username)
    end

    it "returns notifications with many senders" do
      notification = create(:sent_notification, user: user, subject: card)
      create_list(:sender, 4, notification: notification)
      create :card_image, card: card
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(1)
      expected_caption = "4 people upvoted your post \"card_name\""
      expect(r.first["caption"]).to eql expected_caption
    end

    it "sends counts in header" do
      notification = build(:notification, user: user, subject: card)
      notification.sent!
      notification.add_sender(create(:user))
      create :card_image, card: card
      http_login device.id, device.access_token
      get "/api/notifications", nil, @env
      expect(response.status).to eql 200
      expect(response.header["Total"]).to eq "1"
      expect(response.header["TotalUnseen"]).to eq "1"
    end
  end
end
