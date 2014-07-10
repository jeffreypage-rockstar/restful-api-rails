require "spec_helper"

describe Hyper::Login do
  let(:user) { create(:user_with_valid_fb) }
  let(:device) { create(:device, user: user) }

  describe "POST /api/login with username and password" do
    let(:pass) { "please123" }

    it "authenticate a valid user, creating a new device token" do
      post "/api/login", username: user.username, password: pass
      r = JSON.parse(response.body)
      expect(response.status).to eql 201
      expect(r["email"]).to eql user.email
      expect(r["id"]).to_not be_blank
      expect(r["auth"]["device_id"]).to_not be_blank
      expect(r["auth"]["access_token"]).to_not be_blank
    end

    it "authenticate a valid user, using the existent device id" do
      post "/api/login", username: user.username,
                         password: pass,
                         device_id: device.id
      r = JSON.parse(response.body)
      expect(response.status).to eql 201
      expect(r["email"]).to eql user.email
      expect(r["id"]).to_not be_blank
      expect(r["auth"]["device_id"]).to eql device.id
      expect(r["auth"]["access_token"]).to_not be_blank
    end

    it "does not authenticate an invalid password" do
      post "/api/login", username: user.username, password: "123testme1"
      expect(response.status).to eql 401
    end

    it "does not authenticate an invalid username" do
      post "/api/login", username: "invalidusername", password: "123testme"
      expect(response.status).to eql 401
    end
  end

  describe "POST /api/login with facebook_token" do
    before do
      # fb api stubs
      allow(FBAuthService).to receive(:get_facebook_id).
                                      with("facebooktokennotsignedup").
                                      and_return("123456")

      allow(FBAuthService).to receive(:get_facebook_id).
                                      with(user.facebook_token).
                                      and_return(user.facebook_id)

      allow(FBAuthService).to receive(:get_facebook_id).
                                       with("invalidfacebooktoken").
                                       and_return(nil)
    end

    it "authenticate with a valid facebook_token" do
      VCR.use_cassette("fb_auth_valid") do
        post "/api/login", facebook_token: user.facebook_token
        r = JSON.parse(response.body)
        expect(response.status).to eql 201
        expect(r["email"]).to eql user.email
        expect(r["id"]).to_not be_blank
        expect(r["auth"]["device_id"]).to_not be_blank
        expect(r["auth"]["access_token"]).to_not be_blank
      end
    end

    it "rejects authentication with an invalid facebook_token" do
      VCR.use_cassette("fb_auth_invalid") do
        post "/api/login", facebook_token: "invalidfacebooktoken"
        expect(response.status).to eql 401
      end
    end

    it "rejects authentication with an inexistent facebook_id" do
      post "/api/login", facebook_token: "facebooktokennotsignedup"
      expect(response.status).to eql 401
    end
  end
end
