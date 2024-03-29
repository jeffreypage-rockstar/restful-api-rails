require "spec_helper"

describe Hyper::V1::Devices do
  let(:device) { create(:device) }
  let(:user) { device.user }

  # ======== GETTING DEVICES ==================
  describe "GET /api/devices" do
    it "requires authentication" do
      get "/api/devices"
      expect(response.status).to eql 401 # authentication
    end

    it "returns the user devices" do
      device.sign_in!
      build(:device, user: user).sign_in!
      http_login device.id, device.access_token
      get "/api/devices", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r.size).to eql(2)
    end
  end

  # ======== UPDATING A DEVICE ==================
  describe "PUT /api/devices/:id" do
    it "requires authentication" do
      put "/api/devices/#{device.id}", push_token: "a-valid-device-token"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent device" do
      http_login device.id, device.access_token
      put "/api/devices/#{user.id}", { push_token: "a-valid-device-token" },
          @env
      expect(response.status).to eql 404
    end

    it "updates an existent device" do
      expect(DeviceRegisterWorker).to receive(:perform_async).once
      http_login device.id, device.access_token
      put "/api/devices/#{device.id}", {
        push_token: "a-valid-device-token"
      }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r["push_token"]).to eql("a-valid-device-token")
    end

    it "does not allow other user put the device" do
      http_login device.id, device.access_token
      other_device = create(:device)
      put "/api/devices/#{other_device.id}", {
        push_token: "a-valid-token"
      }, @env
      expect(response.status).to eql 403 # forbidden
    end
  end

  # ======== UNREGISTERING A DEVICE PUSH TOKEN ==================

  describe "DELETE /api/devices/:id/push_token" do
    it "requires authentication" do
      delete "/api/devices/#{device.id}/push_token"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent device" do
      http_login device.id, device.access_token
      delete "/api/devices/#{user.id}/push_token", nil, @env
      expect(response.status).to eql 404
    end

    it "unregister an existent device" do
      http_login device.id, device.access_token
      delete "/api/devices/#{device.id}/push_token", nil, @env
      expect(response.status).to eql 204
    end

    it "does not allow other user unregister the device" do
      http_login device.id, device.access_token
      other_device = create(:device)
      delete "/api/devices/#{other_device.id}/push_token", nil, @env
      expect(response.status).to eql 403 # forbidden
    end
  end

  # ======== DELETING A DEVICE ==================

  describe "DELETE /api/devices/:id" do
    it "requires authentication" do
      delete "/api/devices/#{device.id}"
      expect(response.status).to eql 401 # authentication
    end

    it "fails for an inexistent device" do
      http_login device.id, device.access_token
      delete "/api/devices/#{user.id}", nil, @env
      expect(response.status).to eql 404
    end

    it "deletes an existent device" do
      http_login device.id, device.access_token
      delete "/api/devices/#{device.id}", nil, @env
      expect(response.status).to eql 204
    end

    it "does not allow other user delete the device" do
      http_login device.id, device.access_token
      other_device = create(:device)
      delete "/api/devices/#{other_device.id}", nil, @env
      expect(response.status).to eql 403 # forbidden
    end
  end

end
