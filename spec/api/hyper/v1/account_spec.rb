require "spec_helper"

describe Hyper::V1::Account do
  let(:fb_token) { Rails.application.secrets.fb_valid_token }
  let(:user) { create(:user_with_valid_fb) }
  let(:device) { create(:device, user: user) }

  # ======== CREATING A USER ACCOUNT WITH PASSWORD==================
  describe "POST /api/user with password" do
    it "creates a new valid user, not confirmed" do
      post "/api/user", email: "user@example.com",
                        username: "username",
                        password: "123testme",
                        location: "New York",
                        bio: "my bio text"
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r["email"]).to eql "user@example.com"
      expect(r["id"]).to_not be_blank
      expect(r["confirmed"]).to eql false
      expect(r["auth"]["device_id"]).to_not be_blank
      expect(r["auth"]["access_token"]).to_not be_blank
      expect(r["location"]).to eql "New York"
      expect(r["bio"]).to eql "my bio text"
      expect(response.header["Location"]).to match "\/user"
    end

    it "requires valid user param" do
      post "/api/user", email: "user@example.com",
                        username: "username??",
                        password: "123testme"
      r = JSON.parse(response.body)
      expect(response.status).to eql 422 # invalid
      expect(r["status_code"]).to eql "invalid_resource"
      expect(r["error"]).to match("username is invalid")
    end

    it "does not accept duplicated email" do
      post "/api/user", email: user.email,
                        username: "otherusername",
                        password: "123testme"
      r = JSON.parse(response.body)
      expect(response.status).to eql 409 # conflict
      expect(r["status_code"]).to eql "conflict"
      expect(r["error"]).to match("email has already been taken")
    end
  end

  # ======== CREATING A USER ACCOUNT WITH FB TOKEN ==================
  describe "POST /api/user with facebook_token" do

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "accepts signups with a valid facebook_token" do
      VCR.use_cassette("fb_auth_valid") do
        post "/api/user", email: "other@example.com",
                          username: "otherusername",
                          facebook_token: fb_token
        expect(response.status).to eql 201 # created
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    it "does not accepts duplicated facebook_ids" do
      existent_token = user.facebook_token
      VCR.use_cassette("fb_auth_valid") do
        post "/api/user", email: "other@example.com",
                          username: "otherusername",
                          facebook_token: existent_token
        expect(response.status).to eql 409 # conflict
      end
    end

    it "does not accepts invalid facebook token" do
      VCR.use_cassette("fb_auth_invalid") do
        post "/api/user", email: "other@example.com",
                          username: "otherusername",
                          facebook_token: "invalidfacebooktoken"
        expect(response.status).to eql 422
      end
    end

    it "does not accepts facebook_token and password together" do
      post "/api/user", email: "other@example.com",
                        username: "otherusername",
                        password: "123testme",
                        facebook_token: "validfacebooktoken"
      expect(response.status).to eql 400
      r = JSON.parse(response.body)
      expect(r["error"]).to match "mutually exclusive"
    end
  end

  # ======== GETTING CURRENT USER INFO ==================
  describe "GET /api/user" do
    it "requires authentication" do
      get "/api/user"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the current user data" do
      http_login device.id, device.access_token
      get "/api/user", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["id"]).to eql(device.user_id)
      expect(r["score"]).to eql(0)
      expect(r["unseen_notifications_count"]).to eql(0)
    end

    it "fails authentication for an invalid device id format" do
      http_login "#{device.id} ", device.access_token
      get "/api/user", nil, @env
      expect(response.status).to eql 401
    end
  end

  # ======== UPDATING CURRENT USER INFO ==================
  describe "PUT /api/user" do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it "requires authentication" do
      put "/api/user"
      expect(response.status).to eql 401 # authentication
    end

    it "does not allow empty e-mail" do
      http_login device.id, device.access_token
      put "/api/user", { email: "" }, @env
      expect(response.status).to eql 422 # invalid
      r = JSON.parse(response.body)
      expect(r["error"]).to match('email can\'t be blank')
    end

    it "updates current user attributes/settings" do
      http_login device.id, device.access_token
      put "/api/user",
          { avatar_url: "http://new_avatar_url",
            location: "New York, NY",
            facebook_token: "valid_facebook_token"
          }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["avatar_url"]).to eql "http://new_avatar_url"
      expect(r["location"]).to eql "New York, NY"
    end

    it "updates current user e-mail, requiring new confirmation" do
      expect(user).to be_confirmed
      http_login device.id, device.access_token
      put "/api/user", { email: "newemail@example.com" }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["unconfirmed_email"]).to eql "newemail@example.com"
      expect(r["confirmed"]).to be_falsey
    end
  end

  # ======== DELETING CURRENT USER ACCOUNT ==================
  describe "delete /api/user" do
    it "requires authentication" do
      delete "/api/user"
      expect(response.status).to eql 401 # authentication
    end

    it "deletes current user account" do
      http_login device.id, device.access_token
      delete "/api/user", nil, @env
      expect(response.status).to eql 204 # no content
    end
  end
end
